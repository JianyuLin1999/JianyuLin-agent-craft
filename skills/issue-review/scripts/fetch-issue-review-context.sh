#!/usr/bin/env bash
# fetch-issue-review-context.sh — 一次性 bundle issue review 所需的全 context 给 LLM
#
# 设计原则:质量 >> token 成本(沿用 issue-create 原则)。
# 全量拉数据,LLM 在 bundle 里做语义判断(5 维度评估)。
# 脚本只做"拿数据",不做语义判断。
#
# 用法:bash fetch-issue-review-context.sh <N>
# 输出:stdout 分段 markdown

set -euo pipefail

ISSUE_NUMBER="${1:?Usage: fetch-issue-review-context.sh <issue-number>}"

# 找仓库根
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
TEMPLATE_DIR="${REPO_ROOT}/.github/ISSUE_TEMPLATE"

# ── §0 Executive Summary ────────────────────────────────
echo "# Issue Review Context 概览 — #${ISSUE_NUMBER}"
echo ""

# 拉目标 issue 元数据
ISSUE_META=$(gh issue view "$ISSUE_NUMBER" --json title,state,labels,author,createdAt,updatedAt,comments 2>/dev/null || echo '{}')

TITLE=$(echo "$ISSUE_META" | jq -r '.title // "(unknown)"')
STATE=$(echo "$ISSUE_META" | jq -r '.state // "(unknown)"')
AUTHOR=$(echo "$ISSUE_META" | jq -r '.author.login // "(unknown)"')
CREATED=$(echo "$ISSUE_META" | jq -r '.createdAt // ""')
UPDATED=$(echo "$ISSUE_META" | jq -r '.updatedAt // ""')
LABELS=$(echo "$ISSUE_META" | jq -r '[.labels[].name] | join(", ") // ""')
COMMENT_COUNT=$(echo "$ISSUE_META" | jq -r '.comments | length')

# 计算天数(macOS / Linux 兼容)
days_since() {
  local ts="$1"
  if [[ -z "$ts" ]]; then echo "?"; return; fi
  if date --version >/dev/null 2>&1; then
    echo $(( ( $(date +%s) - $(date -d "$ts" +%s) ) / 86400 ))
  else
    echo $(( ( $(date +%s) - $(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null || echo 0) ) / 86400 ))
  fi
}

DAYS_CREATED=$(days_since "$CREATED")
DAYS_UPDATED=$(days_since "$UPDATED")

# placeholder?
PLACEHOLDER="false"
echo "$LABELS" | grep -q 'placeholder' && PLACEHOLDER="true"

echo "- **目标 issue**:#${ISSUE_NUMBER} · ${TITLE}"
echo "- **状态**:${STATE}"
echo "- **作者**:${AUTHOR}"
echo "- **labels**:${LABELS}"
echo "- **placeholder**:${PLACEHOLDER}"
echo "- **创建至今**:${DAYS_CREATED} 天前 / **最近更新**:${DAYS_UPDATED} 天前"
echo "- **评论数**:${COMMENT_COUNT}"

# 关联 PR(从 body / comments grep #数字 模式,粗筛)
ISSUE_BODY=$(gh issue view "$ISSUE_NUMBER" --json body --jq '.body' 2>/dev/null || echo "")
ALL_TEXT="${ISSUE_BODY} $(echo "$ISSUE_META" | jq -r '.comments[]?.body')"
LINKED_REFS=$(echo "$ALL_TEXT" | grep -oE '#[0-9]+' | sort -u | head -10 | tr '\n' ' ')
if [[ -n "$LINKED_REFS" ]]; then
  echo "- **引用过的 #号**(粗筛,LLM 判断哪些是真关联 PR / issue):${LINKED_REFS}"
fi

# 历史 audit 尾巴(沿用 pr-review 设计,看是否被 review 过)
AUDIT_COUNT=$(echo "$ALL_TEXT" | grep -c '<!-- audit:' || echo "0")
if [[ "$AUDIT_COUNT" == "0" ]]; then
  echo "- **历史 audit 尾巴**:0 条(first review,LLM 跑 full)"
else
  echo "- **历史 audit 尾巴**:${AUDIT_COUNT} 条(LLM 看本段评论历史决定增量)"
fi

echo ""
echo "_概览段是 deterministic 事实统计。5 维度评估留给 LLM_"
echo ""
echo "---"
echo ""
echo "# 详细信息"
echo ""

# ── §1 目标 Issue 全文 + Comments ────────────────────
echo "---SECTION-TARGET-ISSUE---"
echo "_LLM 做 5 维度评估的核心数据_"
echo ""
gh issue view "$ISSUE_NUMBER" \
  --json title,body,labels,author,createdAt,comments 2>/dev/null \
  | jq -r '"### Title\n\(.title)\n\n### Labels\n\([.labels[].name] | join(", "))\n\n### Author / Created\n\(.author.login) · \(.createdAt)\n\n### Body\n\(.body)\n\n### Comments (\(.comments | length))\n\(.comments | map("---\n**\(.author.login)** @ \(.createdAt):\n\n\(.body)") | join("\n\n"))"' \
  || echo "(failed to fetch issue #${ISSUE_NUMBER})"
echo ""

# ── §2 3 个 Sedna Templates(评估完整度用)─────────────
echo "---SECTION-TEMPLATES---"
echo "_LLM 用 template 的必填字段评估 B 完整度维度_"
echo ""
for t in bug-report.yml prd-proposal.yml project-gap.yml; do
  if [[ -f "${TEMPLATE_DIR}/${t}" ]]; then
    echo "### ${t}"
    echo '```yaml'
    cat "${TEMPLATE_DIR}/${t}"
    echo '```'
    echo ""
  fi
done

# ── §3 其他 Open Issues(检测唯一性 — 排除目标 issue 本身)─
echo "---SECTION-OTHER-OPEN-ISSUES---"
echo "_LLM 用于 C 唯一性维度(语义匹配现有 open issue)_"
echo ""
gh issue list --state open --limit 500 \
  --json number,title,body,labels,createdAt 2>/dev/null \
  | jq -r --arg n "$ISSUE_NUMBER" '.[] | select(.number != ($n | tonumber)) | "### #\(.number) · \(.title)\n- labels: \([.labels[].name] | join(", "))\n- created: \(.createdAt)\n- body:\n```\n\(.body | .[:1500])\n```\n"' \
  || echo "(no other open issues)"
echo ""

# ── §4 Placeholder Issues 高亮 ───────────────────────
echo "---SECTION-PLACEHOLDER-ISSUES---"
echo "_这些是占位 issue,如果目标 issue 跟它们相关,可能该合并或升级_"
echo ""
gh issue list --state open --label placeholder --limit 100 \
  --json number,title,body,createdAt 2>/dev/null \
  | jq -r --arg n "$ISSUE_NUMBER" '.[] | select(.number != ($n | tonumber)) | "### #\(.number) · \(.title) · created \(.createdAt)\n```\n\(.body | .[:1000])\n```\n"' \
  || echo "(no other placeholder issues)"
echo ""

# ── §5 最近 90 天 Closed Issues ──────────────────────
echo "---SECTION-RECENT-CLOSED-ISSUES---"
echo "_检测目标 issue 是否已被解决 / 关闭过_"
echo ""
if date --version >/dev/null 2>&1; then
  CUTOFF=$(date -d "90 days ago" +%Y-%m-%d)
else
  CUTOFF=$(date -v-90d +%Y-%m-%d)
fi
gh issue list --state closed --search "closed:>${CUTOFF}" --limit 200 \
  --json number,title,closedAt,stateReason 2>/dev/null \
  | jq -r '.[] | "- #\(.number) · \(.title) · closed \(.closedAt) · reason: \(.stateReason // "(none)")"' \
  || echo "(no recent closed issues)"
echo ""

# ── §6 项目方向文档(E 维度:跟方向一致)──────────────────
echo "---SECTION-PROJECT-DIRECTION-DOCS---"
echo "_LLM 用这些做 E 项目方向一致维度评估_"
echo ""

print_doc_if_exists() {
  local path="$1"
  local label="$2"
  if [[ -f "$path" ]]; then
    echo "### ${label}"
    echo '```markdown'
    cat "$path"
    echo '```'
    echo ""
  fi
}

print_doc_if_exists "${REPO_ROOT}/AGENTS.md" "AGENTS.md"
print_doc_if_exists "${REPO_ROOT}/handoff.md" "handoff.md"
print_doc_if_exists "${REPO_ROOT}/CLAUDE.md" "CLAUDE.md(项目级,如果存在)"

# PRDs(列出全部 + 拉内容)
echo "### docs/prd/*.md(全部 PRD)"
echo ""
if ls "${REPO_ROOT}"/docs/prd/*.md >/dev/null 2>&1; then
  for f in "${REPO_ROOT}"/docs/prd/*.md; do
    echo "#### $(basename "$f")"
    echo '```markdown'
    cat "$f"
    echo '```'
    echo ""
  done
else
  echo "(无 docs/prd/*.md)"
  echo ""
fi

# Plans
echo "### plans/*.md(全部 plan)"
echo ""
if ls "${REPO_ROOT}"/plans/*.md >/dev/null 2>&1; then
  for f in "${REPO_ROOT}"/plans/*.md; do
    echo "#### $(basename "$f")"
    echo '```markdown'
    cat "$f"
    echo '```'
    echo ""
  done
else
  echo "(无 plans/*.md)"
  echo ""
fi

# Philosophy(可能很大,只列文件名 + 第一页)
echo "### docs/philosophy/*.md(哲学母版,列出 + 首 2000 字)"
echo ""
if ls "${REPO_ROOT}"/docs/philosophy/*.md >/dev/null 2>&1; then
  for f in "${REPO_ROOT}"/docs/philosophy/*.md; do
    echo "#### $(basename "$f")"
    echo '```markdown'
    head -c 2000 "$f"
    echo ""
    echo "(...截断,完整文件:$(basename "$f"))"
    echo '```'
    echo ""
  done
else
  echo "(无 docs/philosophy/*.md)"
  echo ""
fi

# Changelogs 最近 10 个
echo "### docs/changelog/(最近 10 个)"
echo ""
if ls "${REPO_ROOT}"/docs/changelog/*.md >/dev/null 2>&1; then
  ls -t "${REPO_ROOT}"/docs/changelog/*.md 2>/dev/null | head -10 | while read -r f; do
    echo "- $(basename "$f")"
  done
else
  echo "(无 docs/changelog/)"
fi
echo ""

# ── §7 关联 PR(如果 issue 引用了 PR)──────────────────
echo "---SECTION-LINKED-PRS---"
echo "_LLM 综合判断哪些 #号是真关联 PR(可能已部分处理本 issue)_"
echo ""
if [[ -n "$LINKED_REFS" ]]; then
  for ref in $LINKED_REFS; do
    num=$(echo "$ref" | tr -d '#')
    # 试图当作 PR 拉,失败说明是 issue 不是 PR
    pr_info=$(gh pr view "$num" --json number,title,state,merged 2>/dev/null || echo "")
    if [[ -n "$pr_info" ]]; then
      echo "$pr_info" | jq -r '"- PR #\(.number) · \(.title) · state=\(.state) merged=\(.merged)"'
    fi
  done
else
  echo "(本 issue body / comments 无 #号引用)"
fi
echo ""

# ── §8 可用 Labels ───────────────────────────────────
echo "---SECTION-LABELS---"
echo "_LLM 评估 labels 是否合理 / 该加减_"
echo ""
gh label list --limit 100 --json name,description 2>/dev/null \
  | jq -r '.[] | "- `\(.name)`: \(.description // "(no description)")"' \
  || echo "(failed to fetch labels)"
echo ""

echo "---END-OF-CONTEXT---"
