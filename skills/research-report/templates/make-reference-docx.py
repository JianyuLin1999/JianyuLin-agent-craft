#!/usr/bin/env python3
"""生成 pandoc reference.docx —— 专业研究报告(格式向标准论文看齐)。

把 pandoc 默认 reference.docx 改成专业报告规范:
  - 正文 Times New Roman 12pt、1.5 倍行距(专业报告舒适值;投稿稿传 2.0)
  - 全文黑色(默认 Heading / TOC Heading 是深蓝绿 0F4761,改纯黑)
  - A4 纸张、页边距 1 inch 四周
  - 标题层级 H1 14 / H2 13 / H3 12pt,加粗、黑
  - 目录标题(TOC Heading)黑色加粗
  - 图注 / 表注左对齐、10pt
  - 中文字符走宋体(eastAsia),英文术语走 Times New Roman

用法:
  python make-reference-docx.py <latin> <cjk> <output.docx> [line_spacing] [paper]
  英文:python make-reference-docx.py "Times New Roman" "" reference-en.docx 1.5 A4
  中文:python make-reference-docx.py "Times New Roman" "SimSun" reference-zh.docx 1.5 A4
  line_spacing 默认 1.5;paper 默认 A4(传 letter 用 US Letter)。
  中文宋体:Windows=SimSun,macOS=Songti SC。

依赖:python-docx;pandoc 在 PATH。
"""
import sys, subprocess
from docx import Document
from docx.shared import RGBColor, Pt, Inches, Mm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

latin   = sys.argv[1] if len(sys.argv) > 1 else "Times New Roman"
cjk     = sys.argv[2] if len(sys.argv) > 2 else ""
out     = sys.argv[3] if len(sys.argv) > 3 else "reference.docx"
spacing = float(sys.argv[4]) if len(sys.argv) > 4 else 1.5
paper   = (sys.argv[5] if len(sys.argv) > 5 else "A4").lower()

subprocess.run("pandoc --print-default-data-file reference.docx > /tmp/_base_ref.docx",
               shell=True, check=True)
d = Document('/tmp/_base_ref.docx')

def set_font(style, size=None, bold=None):
    f = style.font
    f.name = latin
    if size is not None: f.size = Pt(size)
    if bold is not None: f.bold = bold
    rpr = style.element.get_or_add_rPr()
    rf = rpr.find(qn('w:rFonts'))
    if rf is None:
        rf = OxmlElement('w:rFonts'); rpr.append(rf)
    rf.set(qn('w:ascii'), latin); rf.set(qn('w:hAnsi'), latin); rf.set(qn('w:cs'), latin)
    if cjk: rf.set(qn('w:eastAsia'), cjk)
    try: f.color.rgb = RGBColor(0, 0, 0)
    except Exception: pass

# 正文:12pt + 1.5 行距
set_font(d.styles['Normal'], size=12)
d.styles['Normal'].paragraph_format.line_spacing = spacing
d.styles['Normal'].paragraph_format.space_after = Pt(6)

# 标题层级 + 目录标题:逐级递减、加粗、黑
for name, size in [('Heading 1', 14), ('Heading 2', 13), ('Heading 3', 12),
                   ('Heading 4', 12), ('Heading 5', 12), ('TOC Heading', 14)]:
    try:
        set_font(d.styles[name], size=size, bold=True)
        d.styles[name].paragraph_format.line_spacing = spacing
    except Exception as e: print('skip', name, e, file=sys.stderr)

# 标题页样式
for name, size, it in [('Title', 16, False), ('Subtitle', 12, True)]:
    try:
        set_font(d.styles[name], size=size)
        d.styles[name].font.italic = it
        d.styles[name].paragraph_format.alignment = WD_ALIGN_PARAGRAPH.CENTER
    except Exception: pass

# 图注 / 表注:左对齐、10pt(遍历 name,避免按 style_id 查找的告警)
for st in d.styles:
    if 'caption' in st.name.lower():
        try:
            set_font(st, size=10)
            st.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.LEFT
            st.font.italic = False
        except Exception: pass

# 纸张 + 页边距
for sec in d.sections:
    if paper == "letter":
        sec.page_width, sec.page_height = Inches(8.5), Inches(11)
    else:
        sec.page_width, sec.page_height = Mm(210), Mm(297)   # A4
    sec.top_margin = sec.bottom_margin = Inches(1)
    sec.left_margin = sec.right_margin = Inches(1)

d.save(out)
print(f"✓ {out} — {latin}/{cjk or '(none)'} 12pt · 行距{spacing} · {paper.upper()} · 全黑 · 1in 边距 · 图注左对齐")
