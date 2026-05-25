#!/usr/bin/env bash
# publish.sh — 把 ~/.pr-review-drafts/pr-{N}-*.md 一键发到 GitHub
#
# 目的:让 user 不需要手动跑一堆 gh CLI 命令。脚本是纯 deterministic 转发器,
# 不修改 draft 内容,只负责 routing 到正确的 gh API。
#
# 用法:
#   bash publish.sh <PR-number>                        发该 PR 的全部 draft
#   bash publish.sh <PR-number> --only=pr              只发 PR comment
#   bash publish.sh <PR-number> --only=issue           只发 issue draft
#   bash publish.sh <PR-number> --only=patch           只显示 patch 文件(不自动 apply)

set -euo pipefail

PR_NUMBER="${1:?Usage: $0 <PR-number> [--only=pr|issue|patch]}"
ONLY=""
if [[ "${2:-}" =~ ^--only=(pr|issue|patch)$ ]]; then
  ONLY="${BASH_REMATCH[1]}"
fi

DRAFTS_DIR="$HOME/.pr-review-drafts"
PUBLISHED=()
SKIPPED=()

if [[ ! -d "$DRAFTS_DIR" ]]; then
  echo "✗ Drafts dir not found: $DRAFTS_DIR"
  echo "  跑过 /pr-review #${PR_NUMBER} 了吗?"
  exit 1
fi

shopt -s nullglob

# ── §1 PR comment(单文件)─────────────────────────────
pr_comment_file="$DRAFTS_DIR/pr-${PR_NUMBER}-comment.md"
if [[ -f "$pr_comment_file" ]]; then
  if [[ -z "$ONLY" || "$ONLY" == "pr" ]]; then
    echo "→ 发 PR comment 到 #$PR_NUMBER..."
    gh pr comment "$PR_NUMBER" --body-file "$pr_comment_file"
    PUBLISHED+=("PR comment: pr-${PR_NUMBER}-comment.md")
  else
    SKIPPED+=("PR comment (--only=$ONLY)")
  fi
fi

# ── §2 Issue drafts(可能多份,按 slug 区分)──────────
for issue_file in "$DRAFTS_DIR"/pr-"${PR_NUMBER}"-issue-*.md; do
  if [[ -z "$ONLY" || "$ONLY" == "issue" ]]; then
    # title 从第一行 `# <title>` 取,body 从第三行开始(跳过 title + 空行)
    title=$(head -1 "$issue_file" | sed -E 's/^#\s*//')
    body=$(tail -n +3 "$issue_file")

    echo "→ 创建 issue: $title"
    issue_url=$(gh issue create --title "$title" --body "$body")
    PUBLISHED+=("Issue: $issue_url")
  else
    SKIPPED+=("Issue draft: $(basename "$issue_file") (--only=$ONLY)")
  fi
done

# ── §3 文档 patch(独立 patch 文件,不自动 apply)──────
for patch_file in "$DRAFTS_DIR"/pr-"${PR_NUMBER}"-doc-patch-*.patch; do
  if [[ -z "$ONLY" || "$ONLY" == "patch" ]]; then
    echo ""
    echo "📄 文档 patch 文件:$(basename "$patch_file")"
    echo "   位置:$patch_file"
    echo "   建议:你在自己的小 PR 里 git apply,review 后 commit"
    PUBLISHED+=("Doc patch listed: $(basename "$patch_file")")
  else
    SKIPPED+=("Doc patch: $(basename "$patch_file") (--only=$ONLY)")
  fi
done

# ── §4 报告 ──────────────────────────────────────────
echo ""
echo "═══ Publish Report ═══"
if [[ ${#PUBLISHED[@]} -gt 0 ]]; then
  echo "✓ 已发布:"
  for item in "${PUBLISHED[@]}"; do
    echo "  - $item"
  done
fi
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo ""
  echo "○ 跳过(--only flag):"
  for item in "${SKIPPED[@]}"; do
    echo "  - $item"
  done
fi
if [[ ${#PUBLISHED[@]} -eq 0 && ${#SKIPPED[@]} -eq 0 ]]; then
  echo "(没找到任何 pr-${PR_NUMBER}-*.md draft 文件)"
fi
