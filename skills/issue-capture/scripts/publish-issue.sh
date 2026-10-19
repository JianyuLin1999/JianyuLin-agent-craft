#!/usr/bin/env bash
# publish-issue.sh — 把 ~/.issue-drafts/issue-{slug}.md 一键发到 GitHub
#
# 设计原则:
#   - 单 draft 默认(安全 + 显式 slug)
#   - --all 批量(capture 多想法场景),≥2 份时强制 confirm
#   - 发布成功 → 归档到 ~/.issue-drafts/published/
#   - 发布失败 → draft 留原位 + 报错
#
# 用法:
#   bash publish-issue.sh <slug>           发单个 draft
#   bash publish-issue.sh --all            发 ~/.issue-drafts/ 下所有 pending draft
#   bash publish-issue.sh --list           列出 pending draft(不发)
#   bash publish-issue.sh --dry-run <slug> 预览发布行为,不真发

set -euo pipefail

DRAFTS_DIR="$HOME/.issue-drafts"
PUBLISHED_DIR="$DRAFTS_DIR/published"

mkdir -p "$DRAFTS_DIR" "$PUBLISHED_DIR"

# ── 参数解析 ───────────────────────────────────────────
MODE="single"
SLUG=""
DRY_RUN="false"

case "${1:-}" in
  --all)    MODE="all" ;;
  --list)   MODE="list" ;;
  --dry-run) DRY_RUN="true"; SLUG="${2:?Usage: publish-issue.sh --dry-run <slug>}" ;;
  "")       echo "✗ 缺少 slug。用法:"; echo "  publish-issue.sh <slug>"; echo "  publish-issue.sh --all"; echo "  publish-issue.sh --list"; exit 1 ;;
  *)        MODE="single"; SLUG="$1" ;;
esac

# ── §1 List 模式 ───────────────────────────────────────
if [[ "$MODE" == "list" ]]; then
  echo "═══ Pending drafts(待发) ═══"
  shopt -s nullglob
  count=0
  for f in "$DRAFTS_DIR"/issue-*.md; do
    count=$((count + 1))
    fname=$(basename "$f" .md)
    title=$(grep -m1 '^# ' "$f" | sed 's/^# *//' | head -c 80)
    template=$(grep -m1 '^template:' "$f" | sed 's/template: *//' || echo "(unknown)")
    placeholder=$(grep -c '^placeholder: true' "$f" 2>/dev/null || echo "0")
    [[ "$placeholder" -gt 0 ]] && placeholder_tag=" 🚧" || placeholder_tag=""
    echo "  ${fname}"
    echo "    → ${title}"
    echo "    → 模板:${template}${placeholder_tag}"
  done
  if [[ $count -eq 0 ]]; then
    echo "  (无 pending draft)"
  fi
  exit 0
fi

# ── 单 draft 发布函数 ──────────────────────────────────
publish_one() {
  local file="$1"
  local slug_name
  slug_name=$(basename "$file" .md | sed 's/^issue-//')

  if [[ ! -f "$file" ]]; then
    echo "  ✗ 文件不存在:$file"
    return 1
  fi

  # 从文件 YAML frontmatter 解析 metadata
  # frontmatter format(在 markdown 文件顶部):
  # ---
  # title: ...
  # template: bug-report | prd-proposal | project-gap
  # labels: ["bug", "internal-test"]
  # placeholder: true | false
  # ---
  local title template labels_str placeholder
  title=$(awk '/^---$/{c++; next} c==1 && /^title:/ {sub(/^title: */, ""); print; exit}' "$file")
  template=$(awk '/^---$/{c++; next} c==1 && /^template:/ {sub(/^template: */, ""); print; exit}' "$file")
  labels_str=$(awk '/^---$/{c++; next} c==1 && /^labels:/ {sub(/^labels: */, ""); print; exit}' "$file")
  placeholder=$(awk '/^---$/{c++; next} c==1 && /^placeholder:/ {sub(/^placeholder: */, ""); print; exit}' "$file")

  # body = frontmatter 之后的内容
  local body_file
  body_file=$(mktemp)
  awk '/^---$/{c++; next} c>=2' "$file" > "$body_file"

  # labels — 从 ["a", "b"] 转成 a,b 格式
  local labels_csv
  labels_csv=$(echo "$labels_str" | tr -d '[]"' | tr -s ' ')
  [[ "$placeholder" == "true" ]] && labels_csv="${labels_csv},placeholder"
  # 去重 + trim
  labels_csv=$(echo "$labels_csv" | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$' | sort -u | paste -sd, -)

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY RUN] 不真发,以下是要执行的命令:"
    echo "  gh issue create \\"
    echo "    --title \"${title}\" \\"
    echo "    --body-file \"${body_file}\" \\"
    echo "    --label \"${labels_csv}\""
    echo ""
    echo "  body preview:"
    head -20 "$body_file" | sed 's/^/    /'
    rm "$body_file"
    return 0
  fi

  echo "  → 创建:${title}"
  local issue_url
  if issue_url=$(gh issue create \
       --title "$title" \
       --body-file "$body_file" \
       --label "$labels_csv" 2>&1); then
    echo "    ✓ ${issue_url}"
    rm "$body_file"
    # 归档
    mv "$file" "$PUBLISHED_DIR/$(basename "$file")"
    return 0
  else
    echo "    ✗ 失败:$issue_url"
    rm "$body_file"
    return 1
  fi
}

# ── §2 Single 模式 ─────────────────────────────────────
if [[ "$MODE" == "single" ]]; then
  file="$DRAFTS_DIR/issue-${SLUG}.md"
  if [[ ! -f "$file" ]]; then
    echo "✗ Draft 不存在:$file"
    echo "  跑 publish-issue.sh --list 看有哪些 pending"
    exit 1
  fi
  echo "═══ 发布单个 issue ═══"
  publish_one "$file"
  exit $?
fi

# ── §3 All 模式 ────────────────────────────────────────
if [[ "$MODE" == "all" ]]; then
  shopt -s nullglob
  files=("$DRAFTS_DIR"/issue-*.md)

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "(无 pending draft,~/.issue-drafts/ 下没有 issue-*.md)"
    exit 0
  fi

  echo "═══ 发现 ${#files[@]} 份 pending draft ═══"
  for f in "${files[@]}"; do
    fname=$(basename "$f" .md)
    title=$(grep -m1 '^title:' "$f" | sed 's/title: *//' | head -c 60)
    template=$(grep -m1 '^template:' "$f" | sed 's/template: *//')
    placeholder=$(grep -c '^placeholder: true' "$f" 2>/dev/null || echo "0")
    [[ "$placeholder" -gt 0 ]] && tag=" 🚧" || tag=""
    echo "  - ${fname} (${template}${tag}) — ${title}"
  done
  echo ""

  # ≥2 份强制 confirm
  if [[ ${#files[@]} -ge 2 ]]; then
    read -r -p "确认全发?(y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "已取消。"
      exit 0
    fi
  fi

  echo ""
  echo "═══ 开始批量发布 ═══"
  success=0
  failed=0
  for f in "${files[@]}"; do
    if publish_one "$f"; then
      success=$((success + 1))
    else
      failed=$((failed + 1))
    fi
  done

  echo ""
  echo "═══ 发布完成 ═══"
  echo "✓ 成功:${success}"
  [[ $failed -gt 0 ]] && echo "✗ 失败:${failed}(draft 留在原位)"
  echo "归档目录:${PUBLISHED_DIR}"
fi
