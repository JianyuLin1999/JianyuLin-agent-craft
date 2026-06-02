#!/usr/bin/env bash
# render.sh — research-report 渲染流水线(LLM 只调这一句,绝不手写排版参数)
#
# 把整条 pipeline 封死:装工具 → Word reference → pandoc docx → 三线表后处理 → typst PDF
# LLM 碰不到 pandoc / typst 参数,就漏不了(典型坑:typst 不在 PATH、漏 shift-heading、漏 toc)。
#
# 用法:render.sh <clean_md> <lang:en|zh> <out_basename> [tool_bin_dir]
#   clean_md      已剥噪音的 markdown(内容层,LLM 产出)
#   lang          en | zh(决定字体:zh 走宋体 eastAsia + 英文术语 Times)
#   out_basename  输出前缀(同目录出 <out>.pdf 和 <out>.docx)
#   tool_bin_dir  pandoc/typst 所在 bin(可选;默认探测 PATH 再找 .sedna/env/bin)
# 出:<out>.docx(Word 主源,可编辑,目录在 Word 里自动更新)+ <out>.pdf(typst,格式完全可控)
set -euo pipefail

MD="$1"; LANG_="$2"; OUT="$3"; BIN="${4:-}"
TPL="$(cd "$(dirname "$0")" && pwd)"

# 工具 PATH:typst 常不在 PATH。优先用户给的 bin,否则探测项目级环境。
[ -n "$BIN" ] && export PATH="$BIN:$PATH"
if ! command -v typst >/dev/null 2>&1; then
  for d in "./.sedna/env/bin" "../.sedna/env/bin" "$HOME/.sedna/env/bin"; do
    [ -x "$d/typst" ] && { export PATH="$(cd "$d" && pwd):$PATH"; break; }
  done
fi
for t in pandoc typst; do
  command -v "$t" >/dev/null 2>&1 || { echo "✗ $t 未找到 — 装:mamba install -c conda-forge pandoc typst" >&2; exit 1; }
done

# 字体:zh 用英文术语 Times + 中文宋体;en 纯英文衬线
if [ "$LANG_" = "zh" ]; then LATIN="Times New Roman"; CJK="SimSun"; else LATIN="Times New Roman"; CJK=""; fi

# 1. Word reference 样式(12pt / 1.5 行距 / A4 / 全黑 / 标题层级 / 图注左对齐)
python3 "$TPL/make-reference-docx.py" "$LATIN" "$CJK" /tmp/_ref.docx 1.5 A4

# 2. Word docx(标题层级 shift -1:## → H1;加目录域)
pandoc "$MD" --reference-doc=/tmp/_ref.docx --shift-heading-level-by=-1 --toc -o "$OUT.docx"
python3 "$TPL/postprocess-docx.py" "$OUT.docx"   # 三线表 + 图注左对齐 + 分页 + 目录域自动更新

# 3. typst PDF(目录/分页/三线表/字体完全可控)
pandoc "$MD" --template="$TPL/report.typ" --pdf-engine=typst --shift-heading-level-by=-1 --toc -o "$OUT.pdf"

echo "✓ 渲染完成:$OUT.docx(Word 主源)+ $OUT.pdf(typst PDF)"
echo "  下一步必跑:python3 $TPL/verify-format.py $OUT.docx $MD"
