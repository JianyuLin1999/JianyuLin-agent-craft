#!/usr/bin/env bash
# publish-issue-review.sh — 把 ~/.issue-review-drafts/issue-review-{N}-comment.md 一键发到 GitHub
#
# 设计:
#   - 主动作:发评论到目标 issue
#   - 可选动作(读 frontmatter):close issue / 加 label / 删 label
#   - 发布成功 → 归档到 ~/.issue-review-drafts/published/
#
# 用法:
#   bash publish-issue-review.sh <N>           发 review draft 到 #N
#   bash publish-issue-review.sh --list        列出 pending review draft
#   bash publish-issue-review.sh --dry-run <N> 预览不真发

set -euo pipefail

DRAFTS_DIR="$HOME/.issue-review-drafts"
PUBLISHED_DIR="$DRAFTS_DIR/published"

mkdir -p "$DRAFTS_DIR" "$PUBLISHED_DIR"

# ── 参数解析 ───────────────────────────────────────────
MODE="single"
ISSUE_NUM=""
DRY_RUN="false"

case "${1:-}" in
  --list)    MODE="list" ;;
  --dry-run) DRY_RUN="true"; ISSUE_NUM="${2:?Usage: publish-issue-review.sh --dry-run <N>}" ;;
  "")        echo "✗ 缺少 issue 编号。用法:"; echo "  publish-issue-review.sh <N>"; echo "  publish-issue-review.sh --list"; exit 1 ;;
  *)         MODE="single"; ISSUE_NUM="$1" ;;
esac

# ── §1 List 模式 ───────────────────────────────────────
if [[ "$MODE" == "list" ]]; then
  echo "═══ Pending issue review drafts ═══"
  shopt -s nullglob
  count=0
  for f in "$DRAFTS_DIR"/issue-review-*-comment.md; do
    count=$((count + 1))
    fname=$(basename "$f" .md)
    target=$(grep -m1 '^target_issue:' "$f" | sed 's/target_issue: *//')
    action=$(grep -m1 '^suggested_action:' "$f" | sed 's/suggested_action: *//')
    will_close=$(grep -m1 '^close:' "$f" | sed 's/close: *//' || echo "false")
    echo "  ${fname}"
    echo "    → 目标 issue:#${target}"
    echo "    → 建议动作:${action}"
    [[ "$will_close" == "true" ]] && echo "    → 会同时 close issue"
  done
  if [[ $count -eq 0 ]]; then
    echo "  (无 pending review draft)"
  fi
  exit 0
fi

# ── §2 Single 模式 ─────────────────────────────────────
file="$DRAFTS_DIR/issue-review-${ISSUE_NUM}-comment.md"
if [[ ! -f "$file" ]]; then
  echo "✗ Draft 不存在:$file"
  echo "  跑 publish-issue-review.sh --list 看有哪些 pending"
  exit 1
fi

# 解析 YAML frontmatter
TARGET=$(awk '/^---$/{c++; next} c==1 && /^target_issue:/ {sub(/^target_issue: */, ""); print; exit}' "$file")
ACTION=$(awk '/^---$/{c++; next} c==1 && /^suggested_action:/ {sub(/^suggested_action: */, ""); print; exit}' "$file")
WILL_CLOSE=$(awk '/^---$/{c++; next} c==1 && /^close:/ {sub(/^close: */, ""); print; exit}' "$file")
LABELS_ADD=$(awk '/^---$/{c++; next} c==1 && /^labels_to_add:/ {sub(/^labels_to_add: */, ""); print; exit}' "$file")
LABELS_REMOVE=$(awk '/^---$/{c++; next} c==1 && /^labels_to_remove:/ {sub(/^labels_to_remove: */, ""); print; exit}' "$file")

# 验证 target 跟文件名一致
if [[ "$TARGET" != "$ISSUE_NUM" ]]; then
  echo "✗ Draft frontmatter target_issue (${TARGET}) 跟命令参数 (${ISSUE_NUM}) 不一致,请检查"
  exit 1
fi

# body = frontmatter 之后
body_file=$(mktemp)
awk '/^---$/{c++; next} c>=2' "$file" > "$body_file"

# 解析 labels 数组(简单格式 ["a", "b"])
parse_labels() {
  echo "$1" | tr -d '[]"' | tr -s ' ' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$'
}

if [[ "$DRY_RUN" == "true" ]]; then
  echo "═══ DRY RUN — 不真发,以下是要执行的命令 ═══"
  echo ""
  echo "1. 发评论:"
  echo "   gh issue comment ${TARGET} --body-file ${body_file}"
  echo ""
  echo "   评论 body 预览:"
  head -20 "$body_file" | sed 's/^/     /'
  echo ""
  if [[ "$WILL_CLOSE" == "true" ]]; then
    echo "2. 同时关闭 issue:"
    echo "   gh issue close ${TARGET}"
    echo ""
  fi
  if [[ -n "$LABELS_ADD" && "$LABELS_ADD" != "[]" ]]; then
    echo "3. 加 labels:"
    parse_labels "$LABELS_ADD" | while read -r l; do
      echo "   gh issue edit ${TARGET} --add-label \"${l}\""
    done
    echo ""
  fi
  if [[ -n "$LABELS_REMOVE" && "$LABELS_REMOVE" != "[]" ]]; then
    echo "4. 删 labels:"
    parse_labels "$LABELS_REMOVE" | while read -r l; do
      echo "   gh issue edit ${TARGET} --remove-label \"${l}\""
    done
  fi
  rm "$body_file"
  exit 0
fi

# 真发
echo "═══ Publishing review for issue #${TARGET} ═══"
echo ""

# 1. 主评论
echo "→ 发评论..."
if ! gh issue comment "$TARGET" --body-file "$body_file"; then
  echo "✗ 评论发布失败,draft 留原位"
  rm "$body_file"
  exit 1
fi
echo "  ✓ 评论已发"

# 2. Close(如果需要)
if [[ "$WILL_CLOSE" == "true" ]]; then
  echo "→ 关闭 issue..."
  if gh issue close "$TARGET"; then
    echo "  ✓ Issue 已关闭"
  else
    echo "  ⚠ 关闭失败(评论已发)"
  fi
fi

# 3. 加 labels
if [[ -n "$LABELS_ADD" && "$LABELS_ADD" != "[]" ]]; then
  echo "→ 加 labels..."
  parse_labels "$LABELS_ADD" | while read -r l; do
    gh issue edit "$TARGET" --add-label "$l" 2>/dev/null && echo "  ✓ 加 ${l}" || echo "  ⚠ 加 ${l} 失败"
  done
fi

# 4. 删 labels
if [[ -n "$LABELS_REMOVE" && "$LABELS_REMOVE" != "[]" ]]; then
  echo "→ 删 labels..."
  parse_labels "$LABELS_REMOVE" | while read -r l; do
    gh issue edit "$TARGET" --remove-label "$l" 2>/dev/null && echo "  ✓ 删 ${l}" || echo "  ⚠ 删 ${l} 失败"
  done
fi

# 归档
rm "$body_file"
mv "$file" "$PUBLISHED_DIR/$(basename "$file")"

echo ""
echo "═══ 完成 ═══"
echo "✓ Review published to issue #${TARGET}"
echo "✓ Draft 已归档到 ${PUBLISHED_DIR}"
