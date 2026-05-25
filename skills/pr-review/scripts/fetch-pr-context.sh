#!/usr/bin/env bash
# fetch-pr-context.sh — 一次性 bundle PR 全 context 给 LLM
#
# 目的:让 LLM 不要重复跑 gh pr view / gh pr diff / gh pr checks 等 deterministic 操作。
# 脚本只做"拿数据",不做语义判断。LLM 拿到 bundle 后仍可用 gh / Grep / Read 自由探索。
#
# 用法:bash fetch-pr-context.sh <PR-number>
# 输出:stdout 分段 markdown,各段标头如 ---SECTION-NAME---

set -euo pipefail

PR_NUMBER="${1:?Usage: $0 <PR-number>}"

# ── §0 Executive Summary(LLM 第一秒看,deterministic 事实统计)─────
# 让 LLM 拿到 high-level picture 后,自然顺着读详细 section。
# 不让 LLM 做"看哪段"的分类决策 — context 本身有层级。
echo "# PR #${PR_NUMBER} 概览"
echo ""

METADATA=$(gh pr view "$PR_NUMBER" --json title,author,state,changedFiles,additions,deletions,isDraft,files 2>/dev/null || echo '{}')

TITLE=$(echo "$METADATA" | jq -r '.title // "(unknown)"')
AUTHOR=$(echo "$METADATA" | jq -r '.author.login // "(unknown)"')
STATE=$(echo "$METADATA" | jq -r '.state // "(unknown)"')
IS_DRAFT=$(echo "$METADATA" | jq -r '.isDraft // false')
CHANGED_FILES=$(echo "$METADATA" | jq -r '.changedFiles // 0')
ADDITIONS=$(echo "$METADATA" | jq -r '.additions // 0')
DELETIONS=$(echo "$METADATA" | jq -r '.deletions // 0')

echo "- **标题**:$TITLE"
echo "- **作者**:$AUTHOR"
echo "- **状态**:${STATE}$([ "$IS_DRAFT" = "true" ] && echo " (Draft)" || true)"
echo "- **改动规模**:${CHANGED_FILES} 文件 / +${ADDITIONS} -${DELETIONS}"

# CI 状态归纳(deterministic — 看 checks 输出有没有 fail/pending 关键词)
CHECKS_OUT=$(gh pr checks "$PR_NUMBER" 2>&1 || echo "")
if echo "$CHECKS_OUT" | grep -qiE "fail|✗"; then
  echo "- **CI 状态**:🔴 有失败"
elif echo "$CHECKS_OUT" | grep -qiE "pending|in_progress|⌛"; then
  echo "- **CI 状态**:⏳ 跑中"
elif [[ -n "$CHECKS_OUT" ]]; then
  echo "- **CI 状态**:✅ 全绿"
else
  echo "- **CI 状态**:(无 checks)"
fi

# 历史 audit 尾巴计数(给增量机制提示)
AUDIT_COUNT=$(gh pr view "$PR_NUMBER" --json comments --jq '.comments[].body' 2>/dev/null | grep -c '<!-- audit:' || echo "0")
if [[ "$AUDIT_COUNT" == "0" ]]; then
  echo "- **历史 audit 尾巴**:0 条(first review,LLM 跑 full)"
else
  echo "- **历史 audit 尾巴**:${AUDIT_COUNT} 条(LLM 用 extract-audit-tails.sh 拿详情决定增量)"
fi

# 其他 open PR + 文件重叠事实(deterministic 集合运算 — 不判断是否真涟漪)
OTHER_PRS=$(gh pr list --state open --json number,headRefName,files --limit 30 2>/dev/null || echo '[]')
OTHER_COUNT=$(echo "$OTHER_PRS" | jq "[.[] | select(.number != $PR_NUMBER)] | length")
CURRENT_FILES=$(echo "$METADATA" | jq -r '.files[]?.path' 2>/dev/null | sort -u)
OVERLAPPING=""
if [[ -n "$CURRENT_FILES" ]]; then
  while IFS= read -r pr_json; do
    pr_num=$(echo "$pr_json" | jq -r '.number')
    [[ "$pr_num" == "$PR_NUMBER" ]] && continue
    other_files=$(echo "$pr_json" | jq -r '.files[]?.path' 2>/dev/null | sort -u)
    if [[ -n "$other_files" ]]; then
      overlap=$(comm -12 <(echo "$CURRENT_FILES") <(echo "$other_files") | head -1)
      [[ -n "$overlap" ]] && OVERLAPPING="${OVERLAPPING}#${pr_num} "
    fi
  done < <(echo "$OTHER_PRS" | jq -c '.[]')
fi
if [[ -n "$OVERLAPPING" ]]; then
  echo "- **其他 open PR**:${OTHER_COUNT} 个(改了同文件:${OVERLAPPING% })"
else
  echo "- **其他 open PR**:${OTHER_COUNT} 个(无文件重叠)"
fi

echo ""
echo "_概览段是 deterministic 事实统计。语义判断(这是真涟漪吗?这件事够不够 ship?)留给 LLM_"
echo ""
echo "---"
echo ""
echo "# 详细信息"
echo ""

# ── §1 PR 元数据 ──────────────────────────────────────────
echo "---PR-METADATA---"
gh pr view "$PR_NUMBER" --json \
  number,title,body,author,state,baseRefName,headRefName,\
mergeable,mergeStateStatus,labels,createdAt,updatedAt,\
changedFiles,additions,deletions,reviewDecision,isDraft,\
url 2>&1 || echo "{}"

# ── §2 PR Diff ───────────────────────────────────────────
echo ""
echo "---PR-DIFF---"
gh pr diff "$PR_NUMBER" 2>&1 || echo "(no diff or error)"

# ── §3 改动的文件清单(带 +/- 行数)───────────────────────
echo ""
echo "---FILES-CHANGED---"
gh pr view "$PR_NUMBER" --json files \
  --jq '.files[] | "\(.additions)\t\(.deletions)\t\(.path)"' 2>&1 || echo "(no files data)"

# ── §4 历史 comment(含 audit 尾巴在内的全部 review 痕迹)─
echo ""
echo "---PR-COMMENTS---"
gh pr view "$PR_NUMBER" --json comments \
  --jq '.comments[] | "### \(.author.login) @ \(.createdAt)\n\(.body)\n"' 2>&1 || echo "(no comments)"

# ── §5 CI / checks 状态 ──────────────────────────────────
echo ""
echo "---CI-CHECKS---"
gh pr checks "$PR_NUMBER" 2>&1 || echo "(no checks or error)"

# ── §6 其他同时 open 的 PR 元数据(横向涟漪 C 用)─────────
echo ""
echo "---OTHER-OPEN-PRS---"
gh pr list --state open --json \
  number,title,headRefName,author,files,updatedAt \
  --limit 30 \
  --jq ".[] | select(.number != $PR_NUMBER)" 2>&1 || echo "[]"

# ── §7 PR 关联的 issue(从 description 解析 Closes #N / Refs #N)─
# 这里只拿 raw description,让 LLM 自己识别引用模式。
# 脚本不固化"引用语法",因为有 Closes / Fixes / Refs / 关联 / Related to 等多种写法
echo ""
echo "---PR-DESCRIPTION-RAW---"
gh pr view "$PR_NUMBER" --json body --jq '.body' 2>&1 || echo ""

# ── §8 项目根目录显式声明文档清单(涟漪 D 用)───────────────
# 脚本只列文档路径,不做 grep — 同义概念识别留 LLM
echo ""
echo "---PROJECT-DOC-LANDMARKS---"
echo "handoff.md"
echo "AGENTS.md"
echo "CONTRIBUTING.md"
ls docs/prd/*.md 2>/dev/null | sort || true
ls plans/*.md 2>/dev/null | sort || true
ls docs/changelog/*.md 2>/dev/null | tail -20 || true
ls docs/philosophy/*.md 2>/dev/null | sort || true

echo ""
echo "---END-OF-CONTEXT---"
