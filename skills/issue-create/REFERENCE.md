# issue-create 详细规则

SKILL.md 是"接到任务时怎么干"的速查,本文件是每一条规则的细节。

`/issue-capture` 也引用这份文档 — 它跟 issue-create 共享 template 路由、文字风格、反模式这几块,只是不做 grill、调研也浅一些。所以你改这里的时候,记得 capture 那边也会同时受影响。

---

## §0 几条根上的判断

### 0.1 信息收集这一步,质量比省 token 重要

`fetch-issue-context.sh` 这一步一次性把 3 份 template + 所有 open issue + placeholder + 90 天 closed 全部拉回来,**不要为了省 token 砍掉哪一类**。

打个比方 — 你在帮一个临床研究员开 PRD,她说"我想加个 X 功能",这时候你脑子里要同时浮现:Sedna 有没有相关的 open issue / 上周她自己 capture 过类似占位没有 / 三个月前讨论过又关掉的有没有。少看一类,你就可能让她重复开一个 issue。Bundle 拉到 100K tokens 都不算夸张,**比她事后发现重复再重开一次便宜得多**。

### 0.2 不脑补 — 但借助 codebase 调研得到的事实不算脑补

这是 issue-create 最特别的纪律,展开讲。

看到一个字段空着时,**不要补全它**。给"代价和风险"字段填"性能影响 / 兼容性风险 / 学习曲线" 这种万能套话是**越权** — user 没说,你不能加;这只是在凑字数。字段没真实信息 → `🚧 待 grill 补完`。留白本身就是一种信息(它告诉协作者"这里待 user 自己说清楚")。

但 issue-create 有个新设计 — 你**应该主动 grep + Read codebase**,把客观事实填进 `Background` 字段。这不是脑补,这是利用你"看代码又多又准"的优势帮 user 补上她说不出来但 codebase 里实实在在存在的东西。

举例感受一下这条线在哪:

user 脑暴 "ipynb 渲染时过滤 cell tag"。

合法 — 你 grep "cell tag" 一遍 codebase,发现 `notebook-renderer.tsx` L142 已经在读 `cell.tags`,`cell.ts` 里 `Cell.tags` 类型是 `string[]`,现有 tag 类型枚举里有 hidden / output / metadata 三种。这些**事实**填进 Background 字段。

不合法 — 你直接写"应该过滤 hidden tag / output tag / metadata tag"放进"推荐方案"字段。user 没说过滤哪些,代码里也只能查到 tag 类型枚举,**查不到 user 想过滤的具体哪个**。这就是脑补。

边界很清楚 — Background 字段填**代码里能验证的事实**,推荐方案 / 范围 / 代价这些 user 主观字段必须 user 说过才填,没说就 🚧。

### 0.3 issue body 用 user 第一人称

这个 issue 是 user 的 GitHub 账号发出去的,作者(可能是 Yennfe,可能是三个月后的 user 自己)打开看的时候,他认为这是 user 本人在写。

所以 body 里全程用"我"陈述 — "我看到 ipynb 渲染时 cell 平铺...",不要"user 在 grill 中说" / "skill 整理到" / "LLM 判断" 这种元描述,这些一漏出来,作者立刻知道这是个 AI 整理的 — 信任感就崩了。

**Background 字段是唯一例外** — 这个字段就是你调研产出的,可以第三人称("我在 codebase 里看到 `notebook-renderer.tsx` L142..."),协作者一眼看出这是 LLM 调研的内容,而不是 user 自己说的。视觉上跟其他 user 第一人称字段分开。

### 0.4 走 Sedna 3 个 template,不绕过

Sedna 强制走 bug / prd / gap 三个模板。**任何"free-form issue"或"自定义字段"都违反**。

为什么这么严 — 因为 Sedna 团队的 issue 是给 3 个月后的自己 / 团队其他人看的,模板字段就是强制的"必须想清楚的几件事"。少填一个字段,就少一份未来回看时的关键信息。

### 0.5 grill 是 `/issue-create` 跟 `/issue-capture` 的唯一差异

其他规则(不脑补 / user 口吻 / template strict / 模板字段)两个 skill 完全共享。

`/issue-create` 必走 grill + 深度 codebase 调研,`/issue-capture` 跳 grill + 只做快速 grep。**user 选 capture 时已经 opt-in 接受"低质量占位"的代价,换取输入零摩擦不丢想法**。两种产物在 inbox 里都看得见,后期可以升级。

---

## §1 template 路由(判断 bug / prd / gap)

拿到 user 输入(那段脑暴文本)后,**对每个识别出来的独立想法**判断它该走哪个模板。

### 判别用的几条线索

| 模板 | 听起来像 | 真实例子 |
|---|---|---|
| **bug-report**(🐛) | "我看到 X 但期望 Y" / "X 行为不对" / "X 偶尔崩" | "docx 预览偶尔崩" / "回车后 10 秒无反应" |
| **prd-proposal**(PRD) | "我建议做 X" / "应该加 Y 功能" / "X 改成 Y 更好" | "ipynb 应该过滤 cell tag" / "大 JSON 用树状渲染" |
| **project-gap**(GAP) | "我发现 X 是问题但不知道方案" / "X 不清楚" | "团队第一次读仓库不知道看啥" / "PRD 跟代码哪边为准" |

### 判断时你要考虑的几条原则

- **听动作语态**:"我看到" → bug;"我建议" → prd;"我发现" / "我担心" → gap
- **看有没有明确方向**:有方向 → prd;只是症状描述 → bug;只是问题感知 → gap
- **看 user 描述到了哪一步**:症状描述 → bug;方向讨论 → prd;问题感知 → gap
- **你自己综合判断,不要按表硬卡**:边界 case 你自己拿主意,user 在综合报告里会 verify

### 万一你 route 错了 — 怎么回头

- 在综合报告里**显式说明你为什么这么 route**("我 route 到 PRD 因为你给了'过滤'这个方向")
- user 在 (1)(2)(3)(4) 这几个选项里看到你选了什么模板,**觉得不对可以选 (4) 重新输入** + 在输入里把语态说明白(eg "这是个 bug,不是 PRD")

---

## §2 grill 怎么跑 — 题数按模板分

### 2.1 grill 的精神(从 grill-me skill 直接抄过来)

> Interview me relentlessly about every aspect of this plan until we reach a shared
> understanding. Walk down each branch of the design tree, resolving dependencies
> between decisions one-by-one. For each question, provide your recommended answer.
>
> Ask the questions one at a time.
>
> If a question can be answered by exploring the codebase, explore the codebase instead.

### 2.2 issue-create 在 grill 上加的几条约束

- **题数按模板分级**(防止 grill 太长把 user 拖累):
  - **prd 模板**:4-5 题(范围 / 代价 / 备选方案 / 验收;有方向但要把它压一压看扛不扛得住)
  - **gap 模板**:3 题(我看到什么 / 影响 / 证据;问题清楚但方案不清楚)
  - **bug 模板**:2 题(重现步骤 / 期望行为;最快收敛,因为信息密度需求低)
- **每题用 clarity-first 风格**:给推荐答案 + 落到具体场景(不堆术语,转化成"你会看到什么")
- **问题尽量带 codebase 证据** — "我看到 `notebook-renderer.tsx` L142 已经在做 Y,你说的 Z 是想在这一层做吗?" 比 "Z 是怎么实现的?" 答得快、答得对。这是新设计的核心 — 你查过代码再问,user 不用从零脑补
- **user 想停 grill**:输入"够了" / "结束" / "stop" → 软结束 → 转 capture 模式(已答字段保留,未答 🚧)→ 继续写 draft

### 2.3 grill 存档怎么写

grill 完之后,**整段问答全文(你的问 + user 的答)直接拼接成 markdown**,填到模板的 "grill-me 存档" 字段:

```markdown
### grill-me 存档

**Q1(LLM)**:[问题原文]

**A1(我)**:[user 原文回答]

**Q2(LLM)**:...

**A2(我)**:...
```

**为什么存全文,不存摘要** — 第一,Sedna 模板就这么要求的。第二,3 个月后 user 自己回看,或者 Yennfe 第一次接手这个 issue,grill 问答的密度远高于一段"摘要"。摘要会把当时为什么这么选 / 当时考虑过哪些 alternative 都丢掉,但这些恰恰是 3 个月后最值钱的。

---

## §3 user 一次塞过来几个想法 — 怎么拆

### 3.1 怎么识别有几个想法

看 user 那段脑暴,识别"这里面其实是几个独立 issue 候选"。

线索:
- 逗号 / 句号 / "而且" / "另外" / "还有" 这些分隔词后面,描述的是另一个主题
- 主题词跳了(eg "ipynb cell" + "docx 崩" + "PDF size" 是 3 个不同模块的问题)
- 你自己综合判断,**不要硬要把它做成可重复的规则**,因为这种识别本来就是语境依赖的

### 3.2 `/issue-create` 怎么处理 — 软询问 user 怎么拆

识别到多想法 → **一次性把所有发现摆出来**:

```
📋 解析结果(确认后才开始 grill):

   想法 1:ipynb 应该过滤 cell tag
   ├ 模板:PRD / 方案草案(因为你给了"过滤"这个推荐方向)
   ├ 疑似重复:#155 文件预览格式支持矩阵(父 issue,讨论过)
   └ 建议:看一下 #155 再决定开新 issue,或者继续(skill 会 grill)

   想法 2:docx 偶尔崩
   ├ 模板:Bug 报告
   ├ 疑似重复:无
   └ 建议:继续,2 题 grill 后建立

   想法 3:PDF >50MB 不该渲染
   ├ 模板:PRD / 方案草案
   ├ 疑似重复:无
   └ 建议:继续

❓ 你想怎么处理?
   (1) 全继续,逐个 grill 完建 3 个 issue
   (2) 只做想法 2 和 3(放弃想法 1,改在 #155 评论)
   (3) 合成 1 个大 issue("file-preview 一揽子改进")
   (4) 重新输入

请选 (1/2/3/4):
```

**几条精神**:
- **你不替 user 决定要不要拆 / 要不要合**(这是 A37 — user 自己的判断权不能被 LLM 截胡)
- 每个想法的模板、重复检测一次性摆出来,不要一项一项问
- 给推荐 + 给 escape hatch(让 user 有 (4) 重新输入的口子)
- 拆分粒度让 user 拿主意

### 3.3 `/issue-capture` 是怎么处理的(详见 capture 的 SKILL.md)

跟 create 不一样:**capture 自动拆,不问 user**。

为什么这样设计 — capture 的定位是"低质量占位",user 选了 capture 就是已经接受"我现在没空,先记下来再说"。这时候你停下来问"是 1 个想法还是 3 个想法?"反而违反了 capture 的精神(零摩擦)。拆错的代价由后期升级时收回。

---

## §4 重复检测 — 检查是不是已经有人开过同样的 issue 了

### 4.1 检测范围

拿到 context bundle 之后,**对每个独立想法**查一遍现有 issue:

- 所有 open issue(title + body 前 2000 字)
- 所有 placeholder issue(**权重更高**,因为 capture 容易产生重复占位)
- 最近 90 天的 closed issue(只看 title,catch "已经被解决或关掉的同样问题")

### 4.2 怎么判断"重复"

你做语义匹配,**不要靠 grep 关键词**。

为什么 — 因为同义概念 grep 抓不到。比如 "渲染" 跟 "预览" 在 Sedna 语境下指的是同一件事,但词不一样,grep 完全错过。你看到 user 说"ipynb 渲染应该过滤 cell tag",要能联想到 #155 那条"文件预览格式支持矩阵"也讨论过 ipynb 这一块。

### 4.3 怎么把发现告诉 user — 软提醒,不挡路

发现疑似重复 → 在综合报告里(§3.2)列出来:

```
   想法 1:ipynb 应该过滤 cell tag
   ├ 疑似重复:#155 文件预览格式支持矩阵(父 issue,讨论过)
   │           #208 ipynb cell tag 占位(你 3 天前 capture 的,placeholder)
   └ 建议:看 #208 是否已包含本想法,如已包含建议升级而非新建
```

**几个关键设计**:
- 只列 title,不替 user 判断("我认为重复" vs "你怎么想"这是 user 的事)
- 给具体的下一步命令(eg "升级 #208" = `/issue-create #208`)
- **不挡路** — 你软提醒一下就接着 grill / 写 draft,不要因为发现疑似重复就停下来不让 user 继续

### 4.4 万一你判断错了 — 假阳性 / 假阴性的兜底

- 假阳性(你说重复但其实不是)→ user 在综合报告里看一眼忽略,继续 grill
- 假阴性(你没看出来重复)→ user 自己 review draft 时发现,或者后续跑 `/issue-inbox` 横向盘点时被 catch(skill 之间互相补漏)

---

## §5 issue-create 特有的文字格式

通用可读性规则(白话 / 路径独立成"位置:"行 / 编号禁入正文)在 SKILL.md 顶部那段 SHARED-READABILITY 里。本节只讲 issue 特有的。

### 5.1 标题强制带前缀

按模板:
- bug → `[BUG] <白话描述>`
- prd → `[PRD] <白话描述>`
- gap → `[GAP] <白话描述>`

✅ `[PRD] ipynb 预览应该支持按 cell tag 过滤`
❌ `[PRD] FileBrowser ipynb renderer cell tag filtering enhancement`

第二个为什么不行 — 它用工程式的命名空间堆词,临床研究员 Yennfe 第一天打开看到这个标题完全不知道在讲什么。

### 5.2 🚧 待 grill 补完 — 留白的字段长这样

某个字段没真实信息可填(user 没说 + codebase 里也没)→ 字段值直接写 `🚧 待 grill 补完`。

**绝不**写 "暂无" / "TBD" / "N/A" — 这些词太低调,后期跑 `/issue-inbox` 横向扫的时候会被漏掉。🚧 这个 emoji 是物理标记,扫一眼就看到哪些字段还没整理完。

### 5.3 user 第一人称具体长什么样

| ✅ | ❌ |
|---|---|
| "我看到 ipynb 平铺所有 cell..." | "user 描述他看到 ipynb 平铺..." |
| "我建议默认隐藏 hidden tag" | "user 在 grill 中提到隐藏 hidden tag" |
| "目前我不清楚做法,可能..." | "user 暂未提出做法" |

每段都用第一人称视角写,**你把自己当成 user 在写**。

唯一例外:Background 字段(详见 §0.2 / §8) — 那段是你调研产出的,用第三人称("我在 codebase 里看到...")。

---

## §6 草稿文件的结构 + frontmatter

### 6.1 文件放哪

`~/.issue-drafts/issue-{slug}.md`

### 6.2 slug 怎么生成

你根据 title 生成 slug:
- 中英文混合 title → 英文 slug(命令行里好操作)
- 全小写 + `-` 连字符
- 不超过 50 字符
- 例:`[PRD] ipynb 预览应该支持按 cell tag 过滤` → `ipynb-preview-cell-tag-filter`

### 6.3 文件格式长这样

```markdown
---
title: [PRD] ipynb 预览应该支持按 cell tag 过滤
template: prd-proposal
labels: ["prd", "needs-review"]
placeholder: false
generated_by: issue-create
generated_at: 2026-05-21T01:30:00Z
---

# [PRD] ipynb 预览应该支持按 cell tag 过滤

## Background — 我调研到的现有代码

> (本字段由 skill 第三人称写,跟 user 主观字段视觉分开)

- `notebook-renderer.tsx` L142 已经在读 `cell.tags`,但没做过滤
- ...

(Sedna template 各字段的填充,按 template 字段顺序)

## 人话摘要

我在做研究分析时,常常打开 100+ cell 的 ipynb,但其实只想看分析结果...

## 要解决的问题

...

## 推荐方案

...

## 范围

做:
- ...
暂缓:
- ...

## 代价和风险

...

## 备选方案和取舍

...

## grill-me 存档

**Q1(LLM)**:...
**A1(我)**:...

...

## 什么算完成

- [ ] ...
- [ ] ...
```

**几条关键约束**:
- frontmatter 是 YAML,`publish-issue.sh` 靠它解析 title / labels / placeholder
- body 是 markdown,直接对应 Sedna template 的字段
- frontmatter 跟 body 之间用 `---` 分隔(标准 markdown frontmatter 格式)

### 6.4 升级模式的草稿

`/issue-create #N` 升级时,草稿文件名仍然用 slug:`issue-{slug}.md`。但 frontmatter 多加:

```yaml
upgrade_target: 208
upgrade_from_placeholder: true
```

`publish-issue.sh` 看到这两个字段后,**会调 `gh issue edit 208 --body-file ...` 而不是 create**(`gh issue create` 会再开一个新 issue,把原占位丢一边,这不是 user 想要的)。

> 实施细节:`publish-issue.sh` 目前只 handle create,升级路径留给场景 2 `/issue-act` skill 时统一 handle。短期手动方案:`gh issue edit 208`。

---

## §7 终端报告长什么样

### 7.1 grill 前的综合解析报告

详见 §3.2 多想法处理的展示形态。

### 7.2 grill 完成后的草稿报告

```
═══ Issue Create Report ═══

📌 已生成 issue draft

   想法 1:[PRD] ipynb 预览应该支持按 cell tag 过滤
   ├ 模板:PRD / 方案草案
   ├ 字段:8/8 已填(0 🚧,含 Background)
   ├ Slug:ipynb-preview-cell-tag-filter
   └ Draft:~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md

📝 准备发布的 issue title 预览:
─────────────────────────────────────────
[PRD] ipynb 预览应该支持按 cell tag 过滤
─────────────────────────────────────────

下一步:
   cat draft:cat ~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md
   一键发布:bash scripts/publish-issue.sh ipynb-preview-cell-tag-filter
```

### 7.3 多 issue 场景(几个想法都通过)

```
═══ Issue Create Report ═══

📌 已生成 3 份 issue draft:

   1. [PRD] ipynb 预览应该支持按 cell tag 过滤   (8/8 字段,无 🚧)
   2. [BUG] docx 预览偶尔崩,无明显复现规律       (6/7 字段,1 🚧 — 重现路径不全)
   3. [PRD] PDF 大于 50MB 不该尝试渲染             (7/8 字段,1 🚧 — 备选方案待补)

下一步:
   list draft:bash scripts/publish-issue.sh --list
   逐个 cat:cat ~/.issue-drafts/issue-{slug}.md
   批量发:bash scripts/publish-issue.sh --all
```

---

## §8 codebase 调研怎么做 — 怎么 grep / 怎么 Read / 怎么提炼 Background

这是 issue-create 跟 issue-capture 最大的差异点之一。capture 只做快速 grep 找一下相关文件路径就够了,**create 必须做深度调研**,把客观事实写进 Background 字段。

### 8.1 调研的三步走

接到一个 user 脑暴,假设是 "ipynb 渲染时应该考虑 cell tag 过滤":

**第一步:基于关键词 grep 一遍 codebase**

挑 user 输入里的关键词(eg "cell tag" / "ipynb 渲染")grep 一遍。不要只 grep 一个 — 同一个概念可能有几种表达,试 2-3 个变体:

- grep "cell.tag" 找代码层面的访问
- grep "ipynb" 找模块入口
- grep "renderer" 找已有渲染管道

目标:找到相关 module 在哪几个文件。

**第二步:Read 关键文件理解结构**

光 grep 字符串远远不够 — 你要 Read 出关键文件,**理解函数调用关系、识别现有模式、发现潜在交互点**。

为什么 Read 而不只 grep — 因为 grep 只告诉你"这个字符串出现在 L142",但不告诉你"L142 这一行在哪个函数里、上下文是什么、有没有相关的逻辑分支"。这些都得 Read 才看得出来。

**第三步:提炼成 Background 字段草稿**

从你 Read 出来的东西里,提炼出客观事实:
- 相关 module / 文件路径 / 行号
- 现有相关代码的简要描述(你 Read 出来的实际内容,不是猜的)
- 潜在交互点 / 已有的类似模式
- 协作者读这段就拿到 codebase 上下文,**不用她再自己 grep 30 分钟**

### 8.2 调研的边界 — 什么时候停

- 三个文件读完已经能写出 5-6 行 Background → 停
- 找不到任何相关代码 → Background 字段写"我在 codebase 里没找到 X 相关的现有实现" + 列你 grep 过的关键词。这本身就是有价值的事实
- 调研过程发现 user 脑暴里 reference 的某个东西**根本不存在**(eg 她说"X 模块",但 codebase 里没有这个模块)→ 在综合报告里提出来问 user,别默默接着写

### 8.3 调研做错了什么样 — 反面例子

❌ **没 grep 就开 grill** — 你直接对着 user 脑暴问"这个 X 是想做在哪一层?",user 也不知道,因为她也没看代码。你白白多 grill 一轮。

❌ **grep 完不 Read,直接把 grep 结果当事实** — 比如 grep 看到 `cell.tags` 出现在 4 个文件,你直接写"现有代码已经在 4 个文件处理 tag"。其实 Read 一看,4 个文件里 3 个只是定义类型,只有 1 个真正在用 — 这种事实的精度差异协作者会立刻感知到。

❌ **把调研结果直接写进 user 主观字段** — 比如把 codebase 里发现的 tag 类型枚举(hidden / output / metadata)直接写进 "推荐方案" 字段当作"过滤这三种"。**这是脑补**(详见 §0.2),user 没说要过滤哪些,代码里也只是枚举,你不能替她决定。这类事实应该在 Background 字段,而推荐方案字段在 user 没说时写 🚧。

---

## §自检 — issue-create 特有的检查项

通用可读性自检(reader 测试 + 7 条手段)在 SKILL.md 顶部 SHARED-READABILITY 那段。本节只列 issue 特有的几条:

| 检查项 | 容忍度 |
|---|---|
| **脑补内容**(你编了 user 没说的、codebase 里也没的东西) | **0** — 改成 🚧 或删除 |
| **第三人称泄露身份**("user 说" / "LLM 整理"出现在 body 里) | **0** — 改成第一人称(Background 字段例外) |
| 模板必填字段没填(也没标 🚧) | **0** — 要么真填要么 🚧 |
| 标题前缀不对(eg [PRD] 写成 [BUG]) | **0** |
| grill-me 存档字段空着(grill 模式下) | **0** — 必须存 grill 全文 |
| Background 字段没做 codebase 调研 | **0** — create 模式必须调研,要么填事实要么写"没找到 + grep 过哪些关键词" |

**自检不可跳**。你默认会脑补 + 默认会第三人称化,自检是唯一拦得住的闸口。

---

## §反模式 — 设计 / 用这个 skill 的时候不能做的事

继承 pr-review 的 4 条通用反模式 + 5 条 issue 特有反模式。

### 通用反模式(继承自 pr-review REFERENCE.md)

1. ❌ 不能把语境依赖的判断硬编码进脚本(template 路由 / 重复检测 / 多想法识别 都让你自己判断)
2. ❌ 不能用穷举检查清单代替开放判据(template 判别只给几条线索,不穷举)
3. ❌ 不能让 skill 记住 user 偏好 / 替 user 抑制提醒(软提醒是默认,不固化 user 倾向)
4. ❌ 设计 prompt 时默认倾向穷举(判据:"我能不能用'你自己判断'代替这 N 行枚举?")

### issue 特有反模式

#### ❌ 不能绕过 Sedna 3 个 template

Sedna 强制走 template,每个 template 有必填字段。**任何"free-form issue"或"自定义字段"都违反**。

实施教训:第一版设计想过 `/issue-create` 出 free-form issue 再加 template 字段当 metadata,被 user 校准回去 strict 走 template。

#### ❌ 不能脑补任何 user 没说的内容(详见 §0.2)

看到一个字段空着时,**不要补全它**。字段没信息 → 🚧。

具体反例:"代价和风险"字段如果 user 没提,**不要**编"性能影响 / 兼容性风险 / 学习曲线"这类通用套话填进去。**这是越权**(user 没说,你不能加),必须改成 🚧。

**但**:借助 codebase 调研得到的客观事实**不算脑补** — 它们走 Background 字段,详见 §0.2 / §8。区别在于 Background 字段填**代码里能验证的事实**,主观字段填**user 说过的话**,两边别串。

#### ❌ 不能在 issue body 里混入 reviewer 内部信息

issue body 用 user 口吻。**绝不出现**:
- "skill 嗅探到 / LLM 判断 / 系统识别"
- "建议动作:create / 阻塞 / 关闭"(这些是 reviewer 内部判断,不该泄露到 user 写出来的 issue body 里)
- audit metadata(eg `<!-- audit: ... -->` 跟 issue 无关,issue 是 user 主动产物)

跟 pr-review 一致:**身份混乱 = 0 容忍**。

#### ❌ 不能让 LLM 替 user 决定 issue 拆分粒度(create 模式)

`/issue-create` 识别到多想法 → 软询问(详见 §3.2),不替 user 决定拆/合。

例外:`/issue-capture` 自动拆(那是 capture 的有意识 trade-off,user 选 capture 时就已经 opt-in 接受了)。

#### ❌ 不能跳过 codebase 调研直接 grill

create 模式下,你在 grill 之前必须先 grep + Read 一遍 codebase(详见 §8)。

为什么这么严 — 没调研就开问,等于把"你看代码又多又准"这个优势浪费掉,user 还要从零回答她原本不知道的问题。这违反了 issue-create 的核心价值。

---

## 附:实战教训

**为什么本 skill 跟 pr-review 风格那么像?**

因为两个 skill 共享同一套核心哲学(不脑补 / 白话 / user 口吻 / 默认严苛),所以章节结构对应。这是 Sedna skill family 的家族风格 — user 在不同 skill 之间切换时心智一致,认知负担低。

**以后怎么调整这份 skill**:

跟 pr-review 一样,实战中发现哪一条判据不够好,就改 REFERENCE.md。每个真实跑过的 issue 都问自己几个问题:

- LLM 有没有脑补?
- 身份有没有泄露(出现 "user 说" / "LLM 整理")?
- 字段完整度对吗?
- grill 题数够不够 / 多不多?
- Background 调研做到位了吗?

发现问题就改 REFERENCE.md,**不要在 skill 外部"用 prompt 修补"** — 应该改判据 / 改自检 / 加反模式。这样下次别人跑这个 skill 也受益,不是只对你一次有效。
