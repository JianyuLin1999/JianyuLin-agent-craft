#!/usr/bin/env bash
# fetch-issue-context.sh — 一次性 bundle issue 创建所需的全 context 给 LLM
#
# 设计原则:质量 >> token 成本(详见 REFERENCE.md §0)。
# 全量拉数据,LLM 在 bundle 里做语义判断。
# 脚本只做"拿数据",不做语义判断。
#
# 用法:
#   bash fetch-issue-context.sh "<user 输入>"           创建模式
#   bash fetch-issue-context.sh --upgrade <N>           升级占位模式
#   bash fetch-issue-context.sh --upgrade <N> "<补充>"  升级 + 补充信息
#
# 输出:stdout 分段 markdown,各段标头如 ---SECTION-NAME---

set -euo pipefail

# ── 参数解析 ───────────────────────────────────────────
MODE="create"
UPGRADE_TARGET=""
USER_INPUT=""

if [[ "${1:-}" == "--upgrade" ]]; then
  MODE="upgrade"
  UPGRADE_TARGET="${2:?Usage: fetch-issue-context.sh --upgrade <N> [\"<补充信息>\"]}"
  USER_INPUT="${3:-}"
else
  USER_INPUT="${1:?Usage: fetch-issue-context.sh \"<user 输入>\" | --upgrade <N>}"
fi

# 找仓库根
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
TEMPLATE_DIR="${REPO_ROOT}/.github/ISSUE_TEMPLATE"

# ── §0 Executive Summary(LLM 第一秒看)──────────────────
echo "# Issue Context 概览"
echo ""

CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "(unknown)")
OPEN_COUNT=$(gh issue list --state open --json number --jq '. | length' --limit 1000 2>/dev/null || echo "0")
PLACEHOLDER_COUNT=$(gh issue list --state open --label placeholder --json number --jq '. | length' --limit 1000 2>/dev/null || echo "0")

echo "- **当前 GitHub 用户**:${CURRENT_USER}"
echo "- **现 open issue 总数**:${OPEN_COUNT}"
echo "- **带 placeholder label 的**:${PLACEHOLDER_COUNT}(后续 /issue-inbox 会 surface)"

# 检查 3 个 template 是否存在
TEMPLATE_STATUS=""
for t in bug-report.yml prd-proposal.yml project-gap.yml; do
  if [[ -f "${TEMPLATE_DIR}/${t}" ]]; then
    TEMPLATE_STATUS="${TEMPLATE_STATUS}${t} ✓ "
  else
    TEMPLATE_STATUS="${TEMPLATE_STATUS}${t} ✗ "
  fi
done
echo "- **3 个 template 状态**:${TEMPLATE_STATUS}"

if [[ "$MODE" == "upgrade" ]]; then
  TARGET_TITLE=$(gh issue view "$UPGRADE_TARGET" --json title --jq '.title' 2>/dev/null || echo "(unknown)")
  TARGET_IS_PLACEHOLDER=$(gh issue view "$UPGRADE_TARGET" --json labels --jq '.labels[].name' 2>/dev/null | grep -c '^placeholder$' || echo "0")
  TARGET_PLACEHOLDER_FLAG="false"
  [[ "$TARGET_IS_PLACEHOLDER" -gt 0 ]] && TARGET_PLACEHOLDER_FLAG="true"
  echo "- **升级目标 issue**:#${UPGRADE_TARGET} - ${TARGET_TITLE} · placeholder=${TARGET_PLACEHOLDER_FLAG}"
fi

echo ""
echo "_概览段是 deterministic 事实统计。语义判断(template route / 重复 / 多想法)留给 LLM_"
echo ""
echo "---"
echo ""
echo "# 详细信息"
echo ""

# ── §1 User Input ────────────────────────────────────
echo "---SECTION-USER-INPUT---"
echo "mode: ${MODE}"
echo "upgrade-target: ${UPGRADE_TARGET:-null}"
echo "raw-input: |"
echo "  ${USER_INPUT}"
echo ""

# ── §2 3 个 Templates 全文 ───────────────────────────
echo "---SECTION-TEMPLATES---"
echo "_LLM 用 template 的描述 / 触发场景 / 必填字段 做 route 判断_"
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

# ── §3 全部 Open Issues(质量优先,不限数量)─────────
echo "---SECTION-OPEN-ISSUES---"
echo "_全部 open issue 的 title + body + labels,LLM 用于多想法重复检测_"
echo ""
gh issue list --state open --limit 500 \
  --json number,title,body,labels,createdAt,author 2>/dev/null \
  | jq -r '.[] | "### #\(.number) · \(.title)\n- labels: \([.labels[].name] | join(", "))\n- created: \(.createdAt)\n- author: \(.author.login)\n- body:\n```\n\(.body | .[:2000])\n```\n"' \
  || echo "(no open issues or gh error)"
echo ""

# ── §4 Placeholder Issues 高亮(重复检测时 weight 更高)─
echo "---SECTION-PLACEHOLDER-ISSUES---"
echo "_这些是占位 issue,重复检测时特别关注(user 可能重复输入相似想法)_"
echo ""
gh issue list --state open --label placeholder --limit 100 \
  --json number,title,body,createdAt 2>/dev/null \
  | jq -r '.[] | "### #\(.number) · \(.title) · created \(.createdAt)\n```\n\(.body | .[:1500])\n```\n"' \
  || echo "(no placeholder issues)"
echo ""

# ── §5 最近 90 天 Closed Issues ──────────────────────
echo "---SECTION-RECENT-CLOSED-ISSUES---"
echo "_最近 90 天 closed issue,catch 已被解决 / 已关闭的同类问题_"
echo ""
# 计算 90 天前日期(macOS / Linux 兼容)
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

# ── §6 Upgrade Context(只在 upgrade 模式)──────────────
if [[ "$MODE" == "upgrade" ]]; then
  echo "---SECTION-UPGRADE-CONTEXT---"
  echo "_升级模式下,这是目标 issue 的完整 body + comments,作为 grill 起点_"
  echo ""
  gh issue view "$UPGRADE_TARGET" \
    --json title,body,labels,comments,author,createdAt 2>/dev/null \
    | jq -r '"### Title: \(.title)\n- author: \(.author.login)\n- created: \(.createdAt)\n- labels: \([.labels[].name] | join(", "))\n\n#### Body\n\(.body)\n\n#### Comments (\(.comments | length))\n\(.comments | map("**\(.author.login)** @ \(.createdAt):\n\(.body)") | join("\n\n---\n\n"))"' \
    || echo "(failed to fetch issue #${UPGRADE_TARGET})"
  echo ""
fi

# ── §7 可用 Labels ───────────────────────────────────
echo "---SECTION-LABELS---"
echo "_repo 可用 labels,template 通常自动加,placeholder label 由 capture 模式手动加_"
echo ""
gh label list --limit 100 --json name,description 2>/dev/null \
  | jq -r '.[] | "- `\(.name)`: \(.description // "(no description)")"' \
  || echo "(failed to fetch labels)"
echo ""

echo "---END-OF-CONTEXT---"
