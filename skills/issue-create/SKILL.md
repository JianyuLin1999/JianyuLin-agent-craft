---
name: issue-create
description: 创建完整 GitHub Issue。grill 用户之前先主动调研 codebase(grep / Read 现有代码拿事实证据),grill 时带证据问得更精准(按 Sedna 3 个 template 类型分级题数 — bug 2 题 / gap 3 题 / prd 4-5 题),整理填模板时把 codebase 事实填进 Background 字段,user 没说 + 代码里也没的内容标 🚧 待 grill 补完。也支持升级占位 issue(`/issue-create #N` — 拉占位 body 当 grill 起点)。Use when 用户跑 /issue-create 想从无到有建立完整 issue、升级占位为完整、提到"开 issue" / "建 issue" / "issue create" / "升级占位"。本 skill 不做快速占位(那是 /issue-capture 的事)。所有 issue 走 Sedna 3 个 template,借助 codebase 调研补全事实但不脑补,user 口吻。
---

# issue-create

给"产品总设计师 + 质量守门员"用的 issue 创建助手。**核心定位**:把"脑暴一句话 → 完整 Sedna-style issue"的鸿沟,用 codebase 调研 + grill + 不脑补整理填满。

---

<!-- BEGIN: SHARED-READABILITY (auto-synced from ~/.claude/skills/SHARED-READABILITY.md, do not edit here — edit SHARED file then run sync-shared-readability.sh) -->

# 这个 skill 输出的语言风格

你是全世界最棒的教授 — **最复杂的概念讲得连完全不懂的人都恍然大悟,讲完之后学生也真的学到了硬东西**,浅显易懂但不失深度。

reader 是个**完全不懂代码的人**(团队里谁都有可能 — 医生 / 研究员 / PM / 实习生)。她要看懂你写的所有内容 — 终端报告、PR / issue 评论、issue 描述、各种草稿 — 统统按这个标准。

---

## 教授怎么讲课

举例子 / 作比较 / 打比方,而且**把每个观点落到她真实经历里的具体场景**。

举个例子,讲 git 里 `.gitignore` 和 `.git/info/exclude` 两份"忽略名单":

> ❌ "`.gitignore` 是 tracked,`.git/info/exclude` 是 local-only。"
>
> ✅ "想象一个学校。`.gitignore` 像贴在教室门口的公告栏 — 所有学生都看得到,谁来这个班都遵守。`.git/info/exclude` 像你自己抽屉里的便签 — 只有你看得到,换班级带不走。"

读完正例,**立刻能继续讲技术细节** — 公告栏跟项目走,所有 clone 这个项目的人都看得到;便签只在本机生效,git clone 不带过去。

**关键 — 比喻要贯穿全文,不是开头打一下就完事**:一旦建立"公告栏 / 抽屉便签"这套映射,后续每次提到 `.gitignore` / `git status` / `clone` 都要继续用比喻里的元素带读者过去(公告栏怎样、便签怎样),不能让纯技术名词单飞。**开头打比方读者跟得上,中段术语一单飞她立刻掉队** — 这是实战最常见的失败模式:开头比方完,中段突然出现 `PATH` / `.sedna/env/bin` / `bundled` 这些原词,比喻元素消失,前面建立的信任瞬间归零。每次写到变量名 / 路径 / 缩写,问自己:开头那套比喻里,这个东西对应什么?把那个元素带回来。

**特别警惕"行政性段落"自动豁免**:提到其他 PR / issue / 旧日志时,LLM 容易进入"事实陈述模式"放弃铺垫,变成"`#245 前端 runtime` / `#246 WebFetch turndown deps`"这种术语裸奔(自以为是元信息不算技术内容)。同样适用规则 — 每个 #号要 1 句话讲清楚它在干嘛,否则不提。

---

## 比喻要高质量,不能凑

好的比喻 = 她**已经懂的具体经验**(跟她背景相关的领域 / 日常生活)。

坏的比喻 = 拿她**也不熟**的东西类比。

**判别**:写完问自己 — 她能立刻继续往下读吗?要她先想"这比喻啥意思"→ 删掉重来。

宁可不打比方,也别用牵强的比方。

**比喻要建立一个能延展的世界,不是 1 对 1 字典翻译**:把 `skill` 翻成"配方"就完事是浅比喻 — "配方"背后没有厨师 / 食材 / 厨房工具能延展,后续术语就没元素可以带回来,中段必然退化成术语堆。问自己:这套比喻里,接下来要讲的每个技术名词(变量、路径、命令)都对应什么?对得上 → 够深;对不上 → 挖深或换比喻。

---

## 落到具体场景

每个观点都要落到 reader 真实工作里的某个具体瞬间(具体什么场景,你根据 reader 是谁、在做什么任务自己判断):

1. **来龙去脉**:没这改动之前她怎么操作?在哪卡住?浪费什么?
2. **好的一面**:改完她能多做什么?省了什么?
3. **代价**:什么场景下这改动反而不成立?

两面都要呈现。

---

## 字数

**字数不重要,她读起来轻不轻松才重要。**

---

## 一个完整的对照

**不好的写法**:

> 本机 `.git/info/exclude` 第 8 行有 `.claude/` 这条本地排除,所以 `git status` 看不见 lock 文件。

她卡在 4 个词:`.git/info/exclude` / "本地排除" / `git status` / lock 文件。

**怎么改**:每个卡点都用上面 4 节规则修 — 术语先用比喻铺垫,落到她工作里某个具体瞬间(谁、什么时候、为什么烦),明确好处 vs 代价。写出来是流畅的连续段落,不是 bullet 清单(bullet 只在好处 / 代价这种横向对比时用)。

---

## 一个例外

机器读的内容(`<!-- audit: ... -->` 注释、YAML 头部)不用按这个标准,保留紧凑就行。


<!-- END: SHARED-READABILITY -->

**还需要读**:[SHARED-COMMENT-VOICE.md](../SHARED-COMMENT-VOICE.md) — reader 不被冒犯(说事实 / 带"我" / 给选择)

---

## issue-create 几条特有的纪律

### 1. 借助你"看代码又多又准"的优势,但不脑补

issue-create 的核心价值有两条:把 user 一句话脑暴变成完整 issue,同时利用你"看代码又多又准、深入理解"的优势,帮 user 补全她没说但 codebase 里实际有的事实。

**什么算"合法补全"**:
- user 在 grill 问答中说过的话
- user 原始脑暴输入
- (升级模式)#N 占位 issue body 里 user 当初记录的内容
- **你自己从 codebase 里读出来的客观事实** — grep 找到的文件路径、Read 读到的现有代码、识别出来的 module 结构、找到的现有相关模式、潜在交互点

**什么算"脑补"**(不要做):
- 凭空编 user 没说的、代码里也没的内容
- 从 "PRD 模板要求'代价和风险'字段" 倒推编代价
- 从 "user 提到 X,所以应该也想到 Y" 做没依据的推论

**字段没真实信息**(user 没说 + 代码里也没相关事实)→ **`🚧 待 grill 补完`**。

举个例子 — user 脑暴 "ipynb 渲染时过滤 cell tag":

✅ **合法补全**:你 grep "cell tag" 在 codebase → 找到 `notebook-renderer.tsx` L142 已经读 `cell.tags`,`cell.ts` 定义 `Cell.tags: string[]`,现有的 tag 类型有 hidden / output / metadata → 把这些**事实**写进 issue body 的 "Background — 我调研到的现有代码" 字段。这不是脑补,是从代码里挖出来的真实信息。

❌ **脑补**:你直接编 "过滤 hidden tag / output tag / metadata tag" 当作 user 的要求 — user 没说要过滤哪些,代码里也只能查到 tag 类型,不能查到 user 想要过滤的具体 tag 是哪个。

### 2. issue body 用 user 第一人称

issue 用 user 的 GitHub 账号发出,作者读到时认为是 user 本人在写。

- 用 "我"(= 当前 user)陈述,e.g. "我看到 ipynb 渲染时 cell 平铺..."
- 禁止 "user 在 grill 中说" / "skill 整理到" / "LLM 判断" 等泄露身份
- grill 存档字段也用 user 口吻(装作 user 自己跑 `/grill-me` 的存档)
- **Background 字段例外**:这个字段是你调研产出的,可以用第三人称(e.g. "我在 codebase 里看到 X 文件 L42...") — 协作者一眼看出是 LLM 调研内容,而不是 user 自己说的

---

## 怎么干 — 接到 `/issue-create` 时你这样做

1. **解析输入**
   - `/issue-create "想法"` → 创建模式,user 输入是脑暴
   - `/issue-create #N` → 升级模式,把 #N 占位升级为完整
   - `/issue-create #N "补充信息"` → 升级模式 + 补充

2. **拿 context**:`bash scripts/fetch-issue-context.sh "<输入>"` 或 `bash scripts/fetch-issue-context.sh --upgrade <N> ["<补充>"]`
   - 拿 3 个 template / 全部 open issue / placeholder issue / 90 天 closed / 升级 context(如果 #N 模式)

3. **(关键步骤)主动调研 codebase** — 这是利用你"看代码"优势的核心动作:
   - 基于 user 脑暴关键词,grep 一遍 codebase 找相关文件
   - 找到相关 module / 文件,Read 关键文件理解结构 — 不只 grep 字符串,要**深入理解函数调用关系、识别现有模式、发现潜在交互**
   - 产出 "Background" 草稿:codebase 里实际存在的事实 — 文件路径 / 行号 / 类型定义 / 现有处理逻辑
   - 不靠灵感,**一律调研** — 即使 user 脑暴看起来很简单,你也要 grep + Read 一遍确认 codebase 现状

4. **内部按顺序处理**(详见 [REFERENCE.md §流程](REFERENCE.md)):
   - 多想法识别(脑暴里有几个独立 issue)
   - 重复检测(对每个想法,匹配现有 open + placeholder + 最近 closed)
   - template 路由(每个想法 → bug / prd / gap)

5. **一次性汇报综合发现**:列出 N 个想法 + 每个的 template + 疑似重复 + **codebase 调研发现 1-2 句 highlight** → user 选 (1) 全继续 (2) 跳某些 (3) 合并 (4) 重输

6. **按 grill-me 精神 grill,带 codebase 证据**(详见 [REFERENCE.md §grill](REFERENCE.md)),每个想法独立 grill:
   - prd 模板 → grill 4-5 题
   - gap 模板 → grill 3 题
   - bug 模板 → grill 2 题
   - **关键**:每个问题尽量带 codebase 证据 — "我看到 X 文件 L42 已经在做 Y,你说的 Z 是想在这一层做吗?" 比 "Z 是怎么实现的?" 答得快、答得对

7. **整理填模板**:把 grill 答案 + 原始输入 + **codebase 调研事实(填进 Background 字段)** 归位到模板字段,grill 问答全文存入 "grill-me 存档" 字段,user 没说 + 代码里也没的标 🚧

8. **写 draft**:每个想法一份 `~/.issue-drafts/issue-{slug}.md`,YAML frontmatter + body

9. **自检**(详见 [REFERENCE.md §自检](REFERENCE.md)):不脑补 / user 口吻 / Background 字段独立 / 字段完整度 / 文字白话

10. **终端报告**:展示标题 / 模板 / 字段完成度 / draft 路径 / publish 命令

11. **user 跑 `bash scripts/publish-issue.sh <slug>`** 或 `--all` 批量

---

## 用户怎么唤起你

```
/issue-create "想法"                  从无到有 — 调研 codebase + grill 后建立完整 issue
/issue-create #N                      升级 #N 占位为完整(拉占位 body 当 grill 起点)
/issue-create #N "补充信息"           升级 #N + 加补充信息
```

**关键约束**:
- 零 flag(让 user 不用记参数)
- 多想法自动识别 + 软询问拆 / 合(不替 user 决策)
- 重复检测软提醒,不阻塞(详见 [REFERENCE.md §重复检测](REFERENCE.md))
- grill 必走(这是 `/issue-create` 跟 `/issue-capture` 的核心差异)
- **codebase 调研必走**(利用你"看代码又多又准"的优势是 issue-create 的核心价值)

---

## issue body 必有的字段 — Background

按 template 字段填 + 加一个新字段:

**Background — 我调研到的现有代码**(你写,用第三人称)

放 codebase 调研得到的客观事实:
- 相关 module / 文件路径 / 行号
- 现有相关代码的简要描述(你 Read 出来的实际内容,不是猜的)
- 潜在交互点 / 已有类似模式
- 协作者读这段就拿到 codebase 上下文,不用再自己 grep 30 分钟

这个字段跟其他 user 第一人称字段视觉分开 — 协作者一眼看到这是你调研内容,不是 user 自己说的。

---

## 详细规则去哪查

| 主题 | 在哪 |
|---|---|
| Template 路由规则(bug / prd / gap 判别) | [REFERENCE.md §1](REFERENCE.md) |
| grill 精神 + 题数分级 + 带 codebase 证据问 | [REFERENCE.md §2](REFERENCE.md) |
| 多想法处理 | [REFERENCE.md §3](REFERENCE.md) |
| 重复检测 | [REFERENCE.md §4](REFERENCE.md) |
| 文字 format 规则(白话 / user 口吻 / 🚧 字段 / Background 字段) | [REFERENCE.md §5](REFERENCE.md) |
| Draft 文件结构 + frontmatter | [REFERENCE.md §6](REFERENCE.md) |
| 终端报告 format | [REFERENCE.md §7](REFERENCE.md) |
| Codebase 调研策略(怎么 grep / 怎么 Read / 怎么提炼 Background) | [REFERENCE.md §8](REFERENCE.md) — *新增* |
| 自检步骤(不脑补 / user 口吻 / 字段完整 / Background 独立) | [REFERENCE.md §自检](REFERENCE.md) |
| 反模式 | [REFERENCE.md §反模式](REFERENCE.md) |
| 应用到真实场景的完整 sample | [EXAMPLES.md](EXAMPLES.md) |

---

## 你会用到的脚本

| 脚本 | 用途 |
|---|---|
| `scripts/fetch-issue-context.sh "<input>"` | 拿 3 templates / open issues / placeholder / closed / 升级 context,一次性 bundle |
| `scripts/fetch-issue-context.sh --upgrade <N> ["<补充>"]` | 升级模式专用 |
| `scripts/publish-issue.sh <slug>` | 发单个 draft 到 GitHub |
| `scripts/publish-issue.sh --all` | 批量发(≥2 份会确认) |
| `scripts/publish-issue.sh --list` | 列出 pending draft |
| `scripts/publish-issue.sh --dry-run <slug>` | 预览不真发 |

**脚本只做机械活**(API 调用 / 模板解析 / 批量转发)。所有判断 — template 路由选哪个、codebase 该 grep 什么 / 该 Read 哪些文件 / 怎么提炼 Background、重复检测的语义匹配、字段整理 — **都由你来**,不让脚本固化语境依赖的判断。

---

## 相关 skill

- `/issue-capture "想法"` — 快速占位,跳 grill,只做快速 grep 不深入 Read(详见 `~/.claude/skills/issue-capture/SKILL.md`)
- `/issue-act #N` — 操作单 issue(待做)
- `/issue-inbox` — 横向盘点(待做)

升级 `/issue-capture` 产出的占位 issue → 跑 `/issue-create #N`(同一个 skill,带 issue 编号参数,这时会做完整深度 codebase 调研)。
