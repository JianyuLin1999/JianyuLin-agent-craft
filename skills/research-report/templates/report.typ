// research-report — 专业研究报告 typst 模板(pandoc --template,出 PDF)
// 格式向标准论文看齐:A4 / 1.5 行距 / 12pt 衬线 / 三线表 / 图注图下左对齐图号粗 /
// front matter 各起页 / 全黑 / 中英文都能排(英文 Libertinus,中文 fallback 宋体)。
// 用法:pandoc report.md --template=report.typ --pdf-engine=typst --shift-heading-level-by=-1 --toc -o report.pdf

#let horizontalrule = v(0.8em)   // markdown 的 --- 不渲染成黑横线,改成间距

// ── 三线表 ──
// pandoc 输出已含 table.header(...) + table.hline()(表头下线现成)。
// 这里:表格默认无线 → block 给整表加顶线 + 底线 → 三线表(顶/表头/底,无竖线无内横线)。
#set table(inset: 7pt, stroke: none)
#show table.hline: set line(stroke: 0.6pt + black)   // 表头下线:细
#show table: it => block(stroke: (top: 1.3pt + black, bottom: 1.3pt + black))[#it]
#show table.cell.where(y: 0): set text(weight: "bold")  // 表头加粗

// ── 页面 / 字体 / 段落 ──
#set page(paper: "a4", margin: 1in, numbering: "1", number-align: center)
#set text(font: ("Libertinus Serif", "Songti SC"), size: 12pt,
          lang: "$if(lang)$$lang$$else$en$endif$", fill: black)
#set par(justify: true, leading: 1em, spacing: 1.3em, first-line-indent: 0pt)  // leading 1em ≈ 1.5 倍行距

// ── 标题层级:编号留给 markdown 手写(numbering: none),按 level 递减字号、加粗、全黑 ──
#set heading(numbering: none)
#show heading: it => block(above: 1.3em, below: 0.7em)[
  #set text(weight: "bold", fill: black,
            size: if it.level == 1 { 14pt } else if it.level == 2 { 13pt } else { 12pt })
  #it
]

// ── 图注:图下方、左对齐、10pt、图号加粗("Figure 1.")──
#show figure.caption: it => block(width: 100%)[
  #set align(left)
  #set text(size: 10pt, fill: black)
  #text(weight: "bold")[#it.supplement #context it.counter.display(it.numbering).] #it.body
]
#show link: set text(fill: black)

// ── 标题页(独占一页)──
#align(center)[
  #v(3.5cm)
  #text(size: 17pt, weight: "bold")[$title$]
  $if(subtitle)$
  #v(0.8em)
  #block(width: 85%)[#text(size: 12pt, style: "italic")[$subtitle$]]
  $endif$
  $if(date)$
  #v(1.5cm)
  #text(size: 11pt)[$date$]
  $endif$
]
#pagebreak()

// ── 目录(独占一页)──
$if(toc)$
#outline(title: [$if(toc-title)$$toc-title$$else$Contents$endif$], depth: 3, indent: auto)
#pagebreak()
$endif$

// ── 正文(Abstract 起;md 在 Abstract 后内置了 typst pagebreak,使 Abstract 独占)──
$body$

// ── 参考文献 ──
$if(bibliography)$
#set bibliography(style: "$if(csl)$$csl$$else$vancouver$endif$")
#bibliography(($for(bibliography)$"$bibliography$"$sep$,$endfor$))
$endif$
