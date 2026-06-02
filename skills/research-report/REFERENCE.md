# research-report REFERENCE

SKILL.md 的详细手册。需要某一块细节时查这里,不必通读。

**核心架构**:格式归固化制品 + 机器自检,LLM 只产内容 + 调脚本,绝不手写排版参数。

---

## §1 一条命令渲染(LLM 的入口)

内容层产出干净 md 后,**只调这一句**,不碰 pandoc / typst 参数:

```bash
bash templates/render.sh <clean.md> <en|zh> <out_basename> [tool_bin_dir]
```

- `render.sh` 封装整条 pipeline:探测装工具 → 生成 Word reference 样式 → pandoc(标题层级 shift -1 + 目录)→ 三线表 / 图注 / 分页后处理 → typst PDF。
- 出 `<out>.docx`(Word 主源)+ `<out>.pdf`(typst)。
- `tool_bin_dir` 可选:pandoc/typst 所在 bin(典型 `<项目>/.sedna/env/bin`)。不给则自动探测 PATH 再找 `.sedna/env/bin`。
- 图相对路径:在报告所在目录(图的父目录)跑,或保证 md 里 `figures/figN.png` 相对 cwd 正确。

**装工具**(render.sh 探测到缺会报错):`mamba install -p <项目>/.sedna/env -c conda-forge pandoc typst`。要 pandoc ≥ 3.1.7(支持 typst 引擎)。**坑:typst 常不在 PATH** —— render.sh 已处理,但手动跑 pandoc 时要 `export PATH=<env>/bin:$PATH`。

---

## §2 为什么双线:typst 出 PDF + pandoc 出 docx

| 格式 | 引擎 | 角色 | 目录 |
|---|---|---|---|
| **PDF** | typst(`report.typ`) | 最终呈现,排版质量最高,格式完全可控 | typst outline 自动生成,填充完整 |
| **Word** | pandoc + `postprocess-docx.py` | 可编辑主源,协作者改 / 投稿用 | Word 域,在真 Word 里打开自动更新 |
| **Markdown** | clean md 本身 | 单一内容源 | 无 |

**为什么 PDF 不从 docx 转**:`soffice --headless` 无头转 PDF **不更新 Word 目录域**(LibreOffice 已知限制),PDF 里目录会空白。typst 出 PDF 目录 / 分页 / 三线表完全可控、质量最高。两者从同一 clean md 出,格式规范由制品对齐一致。

---

## §3 专业报告格式规范(全部固化在制品里,LLM 不手写)

定位:**专业研究报告,格式向标准论文看齐**(不是投稿即用稿,所以不用 double-space)。

| 维度 | 规格 | 固化在 |
|---|---|---|
| 纸张 / 页边距 | A4 / 四周 1 inch | report.typ + make-reference-docx.py |
| 正文字体 | 英 Times New Roman / 中宋体,12pt,术语保留英文 | 同上 |
| 行距 | **1.5 倍**(专业报告;传 2.0 = 投稿 double-space) | make-reference-docx.py 参数 |
| 多级标题 | H1 14 / H2 13 / H3 12pt,加粗、全黑,编号 `1`/`1.1`(md 手写) | 两个模板;pandoc `--shift-heading-level-by=-1` 让 `##`→H1 |
| 三线表 | 顶线(粗)/ 表头下线(细)/ 底线(粗),无竖线无内横线,表头加粗 | postprocess-docx.py(docx)+ report.typ(PDF) |
| 图 | 居中;图注图下方、左对齐、10pt、图号加粗(`Figure 1.`) | 同上 |
| 分页 | 标题页 / 目录 / 摘要各独占,正文连续 | report.typ pagebreak;postprocess page_break_before |
| 颜色 | 全文黑色(默认 Heading 是蓝绿 0F4761,已改黑) | 两个模板 |

**改格式 = 改制品**(改完所有报告一起受益),绝不在 md 塞排版指令、绝不让 LLM 即兴写 typst/docx 参数。

---

## §4 机器自检(verify-format.py)—— 格式"绝对正确"的保障

渲染后**必跑**,把"格式对不对"从人眼主观变成机器客观断言:

```bash
python3 templates/verify-format.py <out>.docx <clean.md>
```

逐项断言(任一不达标 → 退出码 1 + 列出失败项):

- **三线表**:每个 docx 表 borders 只顶/底,无 insideV / insideH
- **全黑 + 衬线**:Normal + Heading 颜色 == 000000、字体 == 衬线
- **行距 / 边距 / 纸张**:1.5 / 1in / A4
- **图注左对齐**:每个 caption 段 alignment == LEFT
- **标题层级连续**:无跳级(H1→H3 ❌)
- **无噪音**(给 md 时):正文无代码块(排除 ```{=typst} raw)/ 脚本名 / 日志名 / 残留 `---`
- **结构完整**:有标题

**失败怎么办**:看哪项 → 改对应制品(report.typ / make-reference-docx.py / postprocess-docx.py)或 clean md → 重渲染 → 重自检。**绝不手写排版参数绕过自检**。绿灯(退出码 0)才算格式正确。

能机械验证的格式项(上面这些,覆盖格式正确性 95%)由此**绝对保证**;主观项(图好不好看、叙事顺不顺)不属"格式"、机器不验。

---

## §5 IMRaD 各节写法

每节 verdict-first(开头一句给结论),术语按惯例保留。

- **摘要 Abstract** —— 背景/方法/主要结果(带关键数字)/结论各一段。读者只读这段也拿到核心判定。
- **背景 Background** —— 研究在问什么、为什么重要、已知什么、补哪个洞。落到具体科学问题。
- **方法 Methods** —— 数据来源、样本、定义、统计方法、预注册假设。够复现,但**不贴代码 / 脚本名 / 复现命令**。
- **结果 Results** —— 按假设 / 主题组织,每个发现 verdict-first + 绑图表证据。图嵌对应结论旁,点明图在论证链的角色。**只报结果不解释意义**(解释留讨论)。
- **讨论 Discussion** —— 意味着什么、跟文献对不对得上、局限、下一步。推论要标清是推论不是结果。
- **副产品 / 意外发现** —— 不符预期的结果科学价值高,单独成节或显式标出,不解释掉、不藏。

---

## §6 图表格式细节

**图**:按正文出现顺序编号(不用文件名顺序);每张配 caption(图号 + 一句话说显示什么);正文引用点明角色;图源进 provenance 不进 caption;缺 / 错 → handoff 不自己画。

**表**:关键数字进正文,完整表进结果节;三线表(制品自动);大而全的调试表(crosstab dump)不进报告或进附录。

---

## §7 噪音剥离清单(内容层,LLM 做;verify 兜底查)

正文**不许出现**:代码块(```python / ```bash)/ shell 命令 / 日志行号引用(`xxx_log.txt lines 112-128`)/ 脚本文件名(`stepN_xxx.py`)/ 复现命令 / 包版本 / 迭代痕迹(`v2`/`v3`/"修正后")/ 调试副产品。

剥噪音 ≠ 删信息:方法学该有的(怎么定义 / 怎么统计 / 什么假设)用**学术语言**重述,不用**工程痕迹**呈现。

---

## §8 现有草稿当内容源

文件夹若已有草稿报告(分析阶段顺手写的),它们是**内容源**不是成品:**挖**(发现 / 效应量 / 判定 / 叙事线 / 讨论)→ **剥**(§7 噪音)→ **重组**(草稿常按分析步骤 step1→7 排,报告按 IMRaD / 假设重组)→ **不照搬**(整篇 copy = 把噪音搬进报告)。多份草稿(中/英/快读/方法)综合成一份权威报告,不简单拼接。

---

## §9 终端报告 format

排版完一段话连着说(不写文件让 user 找):覆盖范围(假设 / 主题)/ 剥了哪些噪音 / 三格式文件落哪(`reports/`)/ **自检是否全绿** / 有无需 handoff 回分析的缺口(缺图 / 数字对不上 / 假设没结果)。

---

## §10 反模式

- ❌ **LLM 手写 typst / docx 排版参数**(最大反模式)—— 格式不稳定的根因。格式走制品 + render + verify,不即兴。
- ❌ 假设排版工具已装就直接跑(render.sh 会探测装;手动跑先 export typst PATH)
- ❌ 渲染完不跑 verify-format.py 就交付(格式没机器背书)
- ❌ 整篇照搬草稿(把噪音搬进报告)
- ❌ 缺图自己用结果数据现画(物理分离,该 handoff)
- ❌ 数字对不上自己补算(报告不重跑分析)
- ❌ 把分析迭代过程(v2/v3)写进报告当叙事
- ❌ 给学术同行的报告里把专业术语用比喻铺垫(reader 错位,这不是 talk-clear 场景)
- ❌ PDF 从 soffice 转 docx 出(目录域不更新 → 目录空白;PDF 走 typst)
