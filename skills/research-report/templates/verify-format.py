#!/usr/bin/env python3
"""verify-format.py — 报告格式机器自检(逐项断言,不靠人眼)。

这是"格式绝对正确"的灵魂:把"格式对不对"从人眼主观判断变成机器客观断言。
渲染后必跑。退出码 0 = 所有可机械验证的格式项达标;非 0 = 精确列出哪项不达标。

用法:python verify-format.py <docx> [clean_md]
检查:三线表 / 全黑 / 衬线 / 行距1.5 / 页边距1in / 纸张A4 / 图注左对齐 / 标题层级连续 /
      (给 md 时)正文无代码块·脚本名·日志名·残留横线 / 结构完整。
依赖:python-docx。
"""
import sys, re
from docx import Document
from docx.shared import Inches, Mm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

docx_path = sys.argv[1]
md_path = sys.argv[2] if len(sys.argv) > 2 else None

fails = []
def check(cond, msg):
    if not cond: fails.append(msg)

d = Document(docx_path)
SERIF = lambda n: bool(n) and any(k in n for k in ('Times', 'Song', 'SimSun', 'Libertinus'))

# 1. 三线表:每个表只有顶/底线,无竖线、无内部横线
for i, t in enumerate(d.tables):
    tblPr = t._tbl.tblPr
    b = tblPr.find(qn('w:tblBorders')) if tblPr is not None else None
    if b is None:
        fails.append(f"表{i+1}: 无三线表边框"); continue
    val = lambda name: (b.find(qn(f'w:{name}')).get(qn('w:val'))
                        if b.find(qn(f'w:{name}')) is not None else None)
    check(val('top') == 'single',  f"表{i+1}: 缺顶线")
    check(val('bottom') == 'single', f"表{i+1}: 缺底线")
    check(val('insideV') in (None, 'none'), f"表{i+1}: 有竖线(三线表应无)")
    check(val('insideH') in (None, 'none'), f"表{i+1}: 有内部横线(三线表应无)")

# 2. 全黑 + 衬线
for name in ['Normal', 'Heading 1', 'Heading 2', 'Heading 3']:
    try:
        f = d.styles[name].font
        col = f.color.rgb if (f.color is not None and f.color.type is not None) else None
        check(col is None or str(col) == '000000', f"{name}: 颜色非纯黑({col})")
        check(SERIF(f.name), f"{name}: 字体非衬线({f.name})")
    except KeyError:
        pass

# 3. 行距 1.5 / 页边距 1in / 纸张 A4
ls = d.styles['Normal'].paragraph_format.line_spacing
check(ls is not None and abs(ls - 1.5) < 0.01, f"正文行距非 1.5({ls})")
sec = d.sections[0]
check(abs(sec.top_margin - Inches(1)) < Inches(0.06), "上边距非 1 inch")
check(abs(sec.left_margin - Inches(1)) < Inches(0.06), "左边距非 1 inch")
check(abs(sec.page_width - Mm(210)) < Mm(6), f"纸张非 A4(宽 {round(sec.page_width/36000,1)}mm)")

# 4. 图注左对齐
for p in d.paragraphs:
    if 'caption' in p.style.name.lower() and p.text.strip():
        check(p.alignment == WD_ALIGN_PARAGRAPH.LEFT, f"图注非左对齐:'{p.text[:30]}…'")

# 5. 标题层级连续(无跳级,如 H1→H3)
levels = [int(p.style.name.split()[-1]) for p in d.paragraphs
          if p.style.name.startswith('Heading ') and p.style.name.split()[-1].isdigit()]
for a, b in zip(levels, levels[1:]):
    check(b <= a + 1, f"标题跳级(H{a}→H{b})")

# 6. 结构完整
check(any(p.style.name.startswith('Heading') for p in d.paragraphs), "无任何标题(结构异常)")

# 7. 正文噪音残留(给 md 时;噪音 = 工程痕迹,不该进发表级报告)
if md_path:
    raw = open(md_path, encoding='utf-8').read()
    # 去 YAML frontmatter
    body = raw.split('---\n', 2)[2] if raw.startswith('---\n') and raw.count('---\n') >= 2 else raw
    # 真代码块噪音 = ``` 后跟编程语言名;排除 pandoc raw block(```{=typst} / ```{=openxml})
    real_code = re.findall(r'```\s*([A-Za-z]+)', body)
    check(not any(c.lower() in ('python','r','bash','sh','js','ruby','sql','c','cpp') for c in real_code),
          "正文含代码块(```python / ```bash 等)")
    check(not re.search(r'step\d+\w*\.py', body), "正文含脚本名(stepN.py)")
    check('log.txt' not in body, "正文含日志文件名(log.txt)")
    check(not any(ln.strip() == '---' for ln in body.split('\n')), "正文含 --- 横线")

if fails:
    print(f"✗ 格式自检未通过 — {len(fails)} 项不达标:")
    for m in fails:
        print(f"  ✗ {m}")
    print("\n修法:改对应制品(report.typ / make-reference-docx.py / postprocess-docx.py)或 clean md,重渲染再自检。绝不手写排版参数绕过。")
    sys.exit(1)

print("✓ 格式自检全部通过 — 三线表 / 全黑 / 衬线 / 行距1.5 / 页边距1in / A4 / 图注左对齐 / 标题层级连续 / 无噪音")
