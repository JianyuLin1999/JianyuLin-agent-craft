# pr-review REFERENCE

完整规则。SKILL.md 是 quick start,这里是细节。

---

## §1 DNA 5 条 —— 哲学冲突嗅探

reviewer **浅看 PR 时最难自己察觉**的硬规则。每条都关于"违反时表现为没东西在代码里"的隐性原则 —— 这是 skill 真正的高价值地带。

### 1. A4 隐式知识断裂 —— "没写下来等于不存在"

**触发模式**:PR 引用某条不在仓库里的约定 / 假设某个本地状态存在 / 协作者不在场就理解不了的 context。

**实证场景**:PR #149 的 Yennfe 看不见用户本地 `CLAUDE.md`(在 `.gitignore` 里),重新写了一份 144 行版本。reviewer 看 PR diff 完全看不出这件事。

### 2. A10 + A40 静默路径 —— 沉默选择 / 错误无可见信号

**触发模式**:出错被 catch 后只打印日志就继续(没向上抛 / 没发事件 / 没记 metric);用户主路径有选择点但没强制记录"为什么选这个";关键失败状态没人订阅。

**实证场景**:#192 的渲染器外壳里,"问每个渲染器能不能处理这个文件"出错时,catch 块吞掉异常静默继续,注释"暂不引入日志依赖"。这是静默吞错的具体落地,但 reviewer 浅看 diff 难以察觉(违反的形态是"没东西在代码里")。

### 3. 0.1 + A39 硬编码 vs LLM 推理的错位

**触发模式**:PR 加 N 步 / M 条 / K 风险点这类硬阈值;或反过来,该硬编码的事用 LLM 临场推理。

**实证场景**:翻译 prompt 写"50 字以内",`ls` 翻 8 字够、复杂文档 50 字截不全 —— 同一个数字不可能同时合身。

### 4. A14 信任梯度错位 —— 当前选档 vs 应该选的档

**触发模式**:PR 实现某能力时选了"LLM 临时生成",但其实有更高一档的路径(做成 Skill / 预编译资产 / 构建时消灭)。

**实证场景**:翻译降级用 LLM 临时生成,本可做成 Skill 预验证。

### 5. 0.2 + A22 活文档过时 —— 文档跟事实脱节

**触发模式**:PR 改了行为但 PRD / 注释 / handoff 没跟着改;或反过来,文档声明的"未来工作"已经没人做但留着。

**实证场景**:`.gitignore` 注释写"Captain-level CLAUDE.md should not be in git",但那份其实是 Dev 操作手册不是 Captain prompt。

---

## §2 涟漪 5 方向

每条 PR 跑 5 个方向的涟漪嗅探。LLM 拿到 `fetch-pr-context.sh` 的 bundle 后,**用语义判断每个方向是否真有涟漪**(脚本不替判断)。

### A. 向后涟漪 —— 代码 → 代码 caller

PR 改了 X,**main 上后续依赖 X** 的代码会怎样?

**怎么嗅探**:diff 改了 API / 函数签名 / 数据结构 → 用 `Grep` 工具找 main 上现有 caller。

**实证场景**:#192 在 `FileBrowser.tsx:249` 把 `fileSize: 0` 当 stub。Phase 4 的 json-tree 按 fileSize 分派会永远不命中,启动前必须改。

### B. 向前涟漪 —— 代码 → plan 后续 phase

PR 改了 X,**plan 后续 phase 还要动 X 吗**?会不会冲突?

**怎么嗅探**:对比 `plans/*.md` 后续 phase 的范围,跟当前 PR 改动的文件 / 概念有交集。

**实证场景**:#192 引入 `RendererHost`,Phase 2 docx 要在它基础上扩。`host.tsx` 顶部注释明示"DOMPurify shell 强制 改成 renderer 自调(v1 折中)" —— Phase 2 docx 必须记得调 sanitizeHtml。

### C. 横向涟漪 —— PR ↔ 同时 open 的其他 PR

同时 open 的其他 PR 跟这条有交集吗?可能 conflict?

**怎么嗅探**:`fetch-pr-context.sh` bundle 里已经包含其他 open PR 的元数据 + files。**LLM 拿到 file 交集后做语义判断**:是真涟漪(改同一逻辑)还是假信号(改同一 file 但完全不相关函数)。

**实证场景**:#194 docx / #197 xlsx 都基于 #192 + 都在 `preview/` 下,合并顺序敏感(谁先合影响 fixture 文件夹的 git history)。

### D. 文档涟漪 —— 代码 → 显式声明文档

PR 改了代码 / 概念,**显式声明文档没跟着更新或者矛盾**?

**怎么嗅探**(LLM 做,不靠 grep 脚本):

| 文档 | 怎么看 |
|---|---|
| `handoff.md` | 测试基线 / 阶段 / 待办 改了吗 |
| `docs/changelog/` | 里程碑级 PR 漏写 changelog |
| `docs/prd/*` | PRD 写"v1 不做 X",PR 偷加 X |
| `plans/*` | Plan 写"Phase 1 范围",PR 越界 |
| `AGENTS.md` §7 文档地图 | 新建 PRD / changelog,§7 没登记 |
| 哲学母版 | PR description cite A22,但 diff 没真正落地 |

**为什么不用 grep 脚本**:文档不会用精确文件名描述代码。比如 PR 改 `host.tsx`,文档里写的是"渲染器外壳" / "Error Boundary 组件" / "DOMPurify 净化层" —— **同义概念,grep 抓不到**。LLM 用语义识别。

### E. 历史涟漪 —— git history / 老注释 / 已废弃设计

PR 改了 X,X 有没有 stale 的"以前的设计"会被破坏?

**实证场景**:`.gitignore` 注释跟新文件用途脱节;函数 jsdoc 说"返回 null",实际抛异常;PRD 声明"放弃方向 Y",代码里还有 Y 的 dead branch。

---

## §3 工程债开放判据

**不穷举检查清单**。给 LLM 这套 prompt 让它自由判断:

```
任务:审查这条 PR 是否达到 ship 级质量。

判据:不只是"能跑",而是"作为长期维护的代码,是否真正足够好"。

哲学锚点(任何一条被违反就 surface,但你不限于这些):
- 单一权威:同一逻辑只在一个地方定义,其他引用不复制
- 抽象层级:没有过度抽象,也没有过度具体
- 隐性债显式化:stub / TODO / @ts-ignore / as any 都该有"为什么 + 何时改"注释
- 命名传达意图:避免 "util" / "helper" / "manager" / "data" 这种空名
- 控制流可读:嵌套深度合理,分支清晰
- 错误处理显式:不静默吞错
- 测试深度匹配代码深度

凡你判断"还可以更好"的地方,surface 出来。

你是质量守门员,不是温和提示者。**默认严苛** —— surface 出来的事默认是 🟡 该改;
只有改进成本明显远大于收益(eg 改一行 vs 重构一周),才降 🟢。

对每条 surface,问自己:"这是局部,还是模式?"
如果是模式,你的 surface 应当呈现这层。

PR 里有没有"顺手改",你**高确信**认为帮了倒忙
(改错 / 引入混乱 / 破坏 scope 外的功能)?
只 surface 这种。良性顺带(typo / 同任务相关的小整理)放过。
```

**核心精神**:开放判据 + 锚点 + LLM 自由判断,不让 reviewer 帮 LLM 想检查清单。LLM 拿到这个 prompt 自由发挥,catch 我们都没想到的第 N 类问题。

### 3.1 7 维度 deterministic 盲点扫描(开放判据的兜底)

开放判据靠语义判断会**阈值漂移** —— LLM 在 "看上去都过" 时自然滑向 0 nit。这 7 维是**机械扫描**(deterministic grep / pattern match),catch 开放判据会漏的常见 nit:

| 维度 | 扫描模式 | 典型 surface |
|---|---|---|
| **① 类型安全** | grep `as unknown as` / `as any` / `// @ts-ignore` / `// @ts-expect-error` / `!` non-null assertion 在 prod 路径 | `as unknown as` 双 cast 跳类型系统;`!` 在用户输入路径会运行时炸 |
| **② 错误处理** | grep `catch.*{}` 空 catch / `catch.*console.` 只 log 不 rethrow / `try.*await.*}` 缺 catch / Promise 无 `.catch` | 静默吞错让用户看到默认值不知道失败了(违 A40) |
| **③ 无障碍配套** | grep `role=` / `aria-` 看 ARIA 是否配套(`role="tab"` 缺 `aria-controls` / `role="dialog"` 缺 `aria-labelledby` / `<img>` 缺 `alt`) | tabs `aria-selected` 但缺 `aria-controls` 指向 tabpanel |
| **④ 跨 codebase 一致性** | 改动里出现的 pattern(eg 用 `react-markdown` / `useCallback` / 错误模式),grep 项目别处怎么做这件事 | 别处 markdown 都传 `remarkPlugins=[remarkGfm]`,本 PR 没传 → 视觉不一致 |
| **⑤ 性能** | grep 改动里:递归遍历 / 嵌套循环 / 同步阻塞 / 大数组 `.filter().map().reduce()` 链 / `useCallback` 依赖数组里高频变化的对象 | `findFileSizeById` 每点击 O(n) 遍历;`useCallback` 加 `allData` 依赖每次重建 |
| **⑥ 文档同步** | diff 中改了:① 公开 API ② 行为契约 ③ 用户可见文案 ④ 配置项 → grep PRD / docstring / changelog / handoff.md 是否跟改 | description 里 "Phase 2 等 review",实际 Phase 2 已合 → 描述过时 |
| **⑦ 测试覆盖度** | 实现里的 discriminated union case(`type X = A \| B \| C`)/ enum / switch 分支,grep 测试里是否每个 case 都有 fixture | ipynb 实现支持 stream / execute_result / display_data / error 4 种 output type,测试只覆盖 stream |

**怎么用**:跑完 DNA / 涟漪后,**按这 7 维各跑一遍 grep / pattern match**,任何命中都进入 surface 候选池,再决定严重度。

**重要**:这 7 维不是穷举,是**最常被 LLM 阈值漂移跳过的几类**。开放判据(§3 的 prompt block)仍然要跑,7 维是兜底不是替代。

### 3.2 心理基线 + 0 nit 强制反思

#### "至少 3 个可改进点" 心理基线

任何 PR 在没找到至少 3 个 surface 之前**都不算审完**。这不是"凑数",是强制扫描深度 —— LLM 默认会在找到 1-2 个就停,这条逼它把 §3.1 的 7 维全跑完 + 开放判据再扫一遍。

**例外**:极端简单的 PR(如改 1 个 typo / 删 1 个 dead import)可以 < 3。但这种情况必须先过 0 nit 反思(下面)。

#### 产出 0 nit 时强制反思 3 条

如果跑完审查产出 0 nit,**publish 前必须自答**:

1. **我有没有用"已验证过的模式"借口跳过?**
   - 反例:"Phase 2 已经这么写了,所以 Phase 3 不再审这个模式"
   - 正确:每个 phase 独立审。前 phase 走过不等于本 phase 没新问题
2. **我有没有用"作者解释过为什么"借口跳过?**
   - 反例:"作者 docstring 写了 lenient 解析是故意的,所以不提"
   - 正确:作者的设计选择仍可质疑。docstring 解释 ≠ 设计无可改进
3. **我有没有用"看上去合理"借口跳过?**
   - 反例:"没看到明显问题,放过"
   - 正确:"没看到" = "我没扫到"。回去把 §3.1 7 维度全跑一遍

3 条都过 + 7 维全扫过 = 真 0 nit,可以 publish。**否则补 surface 重新 draft**。

#### 复盘 example(#198 用新机制会怎样)

**旧 review 产出**:0 nit,"教科书级落地"

**新机制走完应该 surface**:
- 🟡 **维度 ①**:`fakeBridge() { return { ready: true } as unknown as CaptainBridge }` 双 cast 跳类型;`getSkillSystem: async () => ({})` 同 stub 问题
- 🟢 **维度 ⑦**:测试只跑 happy path,handler 返回 404 / 路径遍历 / 权限错误等错误路径无回归保护(虽然本 PR scope 是 stream 不变量,但顺带 surface 让作者知道这部分仍是 gap)

→ 至少 2 个 surface,过"至少 3 个"基线还差 1 个 → 触发 0 nit 反思第 1 条(我有没有因为"Phase 1-2 立的模式"借口跳过?),回去再扫一遍找第 3 个。

---

## §4 文字 format 规则

所有 draft 共享。这是 SKILL.md 顶部"说人话铁律"的物理载体。

**判定根基**:作者在地铁上手机读,每段 30 秒读懂"是好事还是坏事 + 该做什么"。读不懂就是写错了。

### 标题

白话动作 / 后果,不堆变量名 / 编号。
- ✅ "代码里有个占位的 0,某阶段启动前必须改成真值"
- ❌ "fileSize: 0 stub"
- ✅ "HTML 净化的设计从'外壳自动包'改成'渲染器自己记得调'"
- ❌ "host.tsx sanitize: shell 强制 → renderer 自调"

### 正文

只用项目内已建立的概念。外部技术词全翻译,**第一次出现配白话**。

- ✅ 项目内反复用过的概念可保留:渲染器 / 沙箱 / 测试 / 注册表 / 渲染器外壳
- ❌ 外部技术词不翻译:DOMPurify / dispatch / ReactNode / iframe sandbox / XSS payload

### 文件路径 / 变量名 / 函数名

**独立成"位置:"行,不混在正文里挡阅读流**。

✅ 这样:
```
作者诚实交代了这个折中。

位置:渲染器外壳代码文件顶部注释。
```

❌ 不这样:
```
作者在 `host.tsx:14-19` 顶部注释诚实交代了这个折中。
```

### 哲学引用 —— 藏在 audit 尾巴

**reviewer audit 用**,**作者看 PR 时 GitHub markdown 自动隐藏**。

```markdown
🟡 [白话标题]

[场景化解释,不堆术语]

位置:[人话描述路径]

—— 把代码跟设计的偏离主动写下来是好习惯。

<!-- audit: file=host.tsx, ripple=D-doc, dna=0.2, severity=yellow -->
```

audit 尾巴字段:
- `file=<path>` —— 主要相关文件(让 reviewer 一眼定位 + 增量机制用)
- `ripple=<A|B|C|D|E>` —— 触发的涟漪方向
- `dna=<原则编号>` —— 触发的 DNA 原则
- `severity=<red|yellow|green>` —— 严重度
- `kind=<positive|concern>` —— 可选,标 positive observation

### 严重度 icon

| icon | 含义 |
|---|---|
| 🔴 | **阻塞 ship,必须改** —— 违反 DNA / 严重隐性破坏(stub 没标记会让后续 phase 沉默踩坑) |
| 🟡 | **应该改** —— 默认大多数 surface 落这里。作者决定本 PR 改还是开新 PR 跟进 |
| 🟢 | **可选改进 / positive observation** —— 真微小,或改成本远大于收益;或"做对了"的正向标识 |

**强制要求**:每个 surface(不论致谢正向 / nit / 阻塞)**必须挂 icon**。无 icon 的 surface 等于没挂级,作者无法快速分流"哪些必改 / 哪些可选"。Layer A 找出问题后,Layer B 写出来时连同 icon 一起挂上 —— icon 是分流信号,不是装饰。

### 完整段落对比 —— 同一件事的术语版 vs 白话版

**情境**:#194 docx 渲染器 PR,你想 surface "mammoth.js 没设 chunk 名,以后排查会绕路"。

**❌ 术语堆砌版(LLM 默认会写成这样)**:

```
🟡 mammoth.js 的 dynamic import 没设 chunkName

vite.config.ts 里 mammoth 用 dynamic import 实现 code splitting,
但没配 webpackChunkName 注释,build 产物的 chunk 文件名是 hash 而非
mammoth-{hash}.js。Debug 时定位 perf 问题要靠 source map 反查,DX 受损。
```

**问题**:作者地铁上读这段,要解码 dynamic import / chunkName / webpackChunkName / chunk / hash / DX 至少 6 个英文术语 + 1 个变量名 + 1 个文件路径混在正文 —— **每个都是阅读阻力**。

**✅ 白话版**:

```
🟡 docx 解析库在打包后名字看不出来是哪个,以后排查性能问题会绕路

docx 文件是用 mammoth 这个工具解析的,代码里设了"用户打开 docx 才加载",
减少首次启动的包大小 —— 这个设计是对的。

但打包工具没给这个工具单独取名,产出的文件名是一串随机字符。

将来某用户报"打开 docx 慢",从浏览器开发者工具里看到的文件名是
`abc123.js` 而不是 `mammoth-abc123.js`,排查时多一步反查映射表。

位置:打包配置文件里 mammoth 的加载语句。

—— 设个明确的名字,以后排查时省一步。

<!-- audit: file=vite.config.ts, ripple=B-forward, dna=A22, severity=yellow -->
```

**对比**:
- 术语版 3 句话用了 8 个术语 + 1 变量名 + 1 文件路径在正文 → 阅读阻力 10 个解码点
- 白话版同样信息量,正文 0 术语,文件路径独立成"位置:"行 → 阅读阻力 1 个(`abc123.js`,但有上下文可推)

**白话版花的字数更多。这是正确的代价** —— 字数多 / 阅读阻力少,胜过字数少 / 阅读阻力多。

### 生成 draft 后的自检 —— LLM 必做,不能跳

写完每份 draft 后,**用作者视角再读一遍**:

> 想象 Yennfe(或者你自己)第一次看到这段,**地铁上手机读**。
> 每段读完,能立刻知道"这是好事还是坏事 + 我该做什么"吗?

如果哪段答案是"不能" → **重写那段**。

**deterministic 判据(发现一条就改)**:

| 判据 | 容忍上限 |
|---|---|
| 一句话里英文技术词没翻译 | ≤ 1 个(且必须配白话括号注释) |
| 变量名 / 函数名 / 文件路径出现在正文 | **0** —— 必须移到"位置:"独立行 |
| 章节号 / DNA 编号(`§X.X` / `A14` / `0.2` / `B7` 等)出现在 PR 评论正文 | **0** —— 编号只能在 audit 尾巴,正文用"白话原则名 + 场景"代替(eg 不写"违反 A14",写"这件事其实有更高一档的路径") |
| 三档严重度大多数是 🟢 | **不允许** —— 默认严苛,大多数应该 🟡 |
| audit 尾巴漏贴 | **0 漏** —— 每条 surface 都要贴 |
| **身份混乱** —— "建宇你看" / "请 user 判断" / "skill 嗅探到" 出现在 PR 评论 | **0** —— 评论用 user 口吻直接对作者说 |
| **reviewer 内部元信息**(建议动作 / 评论预览 / surface 统计文字)出现在 PR 评论 | **0** —— 这些只在终端报告里给 user 看 |

**主观判据(LLM 自己判)**:

- 每段开头一句话能不能"独立成立"?(作者只读这一句也明白大意)
- 推理链有没有跳步?(因为 A → 直接 → D,中间 B 和 C 消失了)
- 我有没有为了显得专业而用了术语?如果有,把它替换成场景描述。

### 跨 skill 共享判据(必跑)

跑完本节判据后,**必须再跑** [`comment-voice.md §7`](../../knowledge-assets/comment-voice.md) 8 条 deterministic 判据。

核心判据摘要(完整见共享文件):
- 句子以 "你没 / 你应该 / 你必须 / 你不能" 开头 → 改成 "我看到 X" 或 "我担心 X" + 给选择(居高临下反模式)
- "立刻做这 N 件事:1. X 2. Y" 形态 → 改成 "N 条路你挑"(指令越权)
- "你大概是 / 可能是因为 / 估计你..." 替对方解释 → 删除,只说事情(替人找借口反模式)
- 预测对方反应("你看完会发现 X" / "你会注意到 Y") → 删除,让对方自己得出结论
- 替对方切片("拆 N 个 PR:第一个 X,第二个 Y") → 改成"建议拆,具体怎么拆对齐后再说"
- 比喻里对方被塑造成"小白 / 新人 / 没经验" → 重写让对方保持设计者 / 同等专业身份
- 收尾"列一堆问题 + 但你基本功是好的"对比结构 → 砍掉对比,要么纯正向,要么不收尾
- 致谢里指不出具体代码 / 动作 / 文档 → 删,空夸比不夸更伤
- "你这份 X 写得很详细 —— 看得出..." 客套开头 → 删,直接进事实
- 总字数超过 comment-voice §5 上限 → 砍过渡 / 元话语 / 客套开头

**自检不可跳**。两套自检(本 skill + 共享文件)都过才能 publish。LLM 默认会在"居高临下"和"替人找借口"两个失败模式之间摇摆,共享自检是 catch 的闸口。

---

## §5 Draft 3 类

### 5.1 PR comment(用 user 口吻直接对作者说)

回应**当前 PR**。**身份必须自洽**:用 "我"(= user,质量守门员)/ "你"(= 作者)的口吻,不出现身份混乱(详见 SKILL.md §1.2 人称纪律)。

#### Component 集合

**必填**(任何 PR 评论都要):

- **整体评价** —— 白话一句话,作者一眼知道这次 review 整体感觉
  - eg "Phase 1 这版比 Phase 0 又高一档,可以直接合 + 启动 Phase 2"
- **具体识别(致谢核心)** —— 至少 1 处"做对了的事",PR 越好识别越多(3-5 处都不嫌多)
- **surface 清单**(没发现就写"未发现",显式)

**可选(按场景填)**:

| 场景 | 加什么 |
|---|---|
| Merge + 启动下一个 Phase | 启动信号段(具体到"物质条件就位清单") |
| 留 🟡 改进 | 改进要求段 |
| 阻塞 🔴 | 阻塞原因段(具体到"为什么必须先改") |

#### ⭐ 高质量致谢提示词(merge 必须致谢,空话致谢比不致谢更伤)

**核心目标**:让作者感受到"我做的努力被精确看见了"。

**每条"具体识别"必须包含 3 个要素**:

1. **这处做了什么** —— 用具体动作命名(eg"把 X 决策搬到 Y 自己声明"),不堆术语
2. **为什么这件事重要 / 难做** —— 原本可能怎样,作者却做对了什么不容易的事
3. **这处做对了带来的连锁好处** —— 对未来 phase / 团队 / 项目长期质量的影响

**对比示范**:

❌ **空话致谢(违反提示词,永远不能这样写)**:
> "辛苦了,这个 PR 整体质量很好,继续保持。"
> "做得很棒,契约测试写得很完整。"

→ 作者读完毫无"被看见"的感觉,跟"已读"差不多。这种致谢比不致谢更伤,因为它说明 reviewer 没认真读 —— 反而打击作者下次认真做的动机。

✅ **高质量致谢(符合提示词)**:
> ### 1. 把"该不该拉文件内容"这个决策搬到每个渲染器自己声明
>
> 旧主组件里硬编码一个"二进制扩展名清单",每加一种格式都得改主组件。
> 现在每个渲染器自己声明"我需不需要预取文件内容",主组件查这个声明决定。
> **从此加新格式不用改主组件**。这是产品哲学里"加格式 = 一个新文件 + 一行注册"的真正落地。

→ 命名了具体动作 + 解释了为什么重要 + 连锁好处。作者读完知道:**我做的这件事被精确看见了,而且对项目长期质量有意义**。

**致谢提示词清单**:

- ✅ 用具体动作命名("把 X 搬到 Y")—— 不要泛泛"做得好"
- ✅ 说出"为什么这件事不容易"或"原本可能怎样"—— 让作者感受到"难度被识别"
- ✅ 连接到未来 phase / 团队 / 项目长期质量 —— 让作者感受到"我的贡献有影响"
- ❌ 不要空话("做得好" / "很棒" / "辛苦了" 单独成段)—— 比不致谢更伤
- ❌ 不要把 surface 的事 wrap 上"瑕不掩瑜"伪装成正面 —— 致谢和 surface 必须分开写
- ❌ 不要堆砌形容词("非常优秀的设计" / "极佳的代码") —— 用事实和后果说话,不用形容词

**merge 必须致谢,例外极少**:

即便是没什么亮点的小 PR(eg 改个 typo / 升级 dep),也至少识别一处具体的事 —— eg "升级的版本号选了 patch 而不是 minor,符合最小风险原则" / "fixture 覆盖了 3 类失败情况,这种边界 case 经常被忽略"。

**不允许 merge 不带致谢**。

**文件位置**:`~/.pr-review-drafts/pr-{N}-comment.md`

### 5.2 Issue 草稿(最简形态)

**触发**:PR review 中发现"新独立工作"(新 bug-class / 跟踪 deferred 事项 / 系统性问题)。

**形态**:title + body,LLM 自己判断写多详细。不强制 component。**等 issue-triage skill 设计完再丰富**。

**文件位置**:`~/.pr-review-drafts/pr-{N}-issue-{slug}.md`

第一行必须是 `# <title>` (publish 脚本会提取作为 issue title)。

### 5.3 文档 patch

**两种形态(skill 自动选,user 不感知)**:

| 场景 | 形态 |
|---|---|
| **PR 内文档没跟上代码**(handoff / changelog / PR 内 docs) | **GitHub Suggestion**(嵌在 PR review comment markdown 块) |
| **跨 PR 文档过时**(PRD / philosophy 矛盾,跟某 PR 没绑定) | **独立 patch 文件** |

#### GitHub Suggestion 形态

嵌在 PR comment 的 markdown 块:
````markdown
建议改成:
```suggestion
新内容
```
````

作者点 "Commit suggestion" 一键应用。

**文件位置**:这种 draft 是 PR comment 的一部分,放在 `pr-{N}-comment.md` 里。

#### 独立 patch 文件形态

完整 `.patch` 文件,user 在自己的小 PR 里 `git apply` + commit。

**文件位置**:`~/.pr-review-drafts/pr-{N}-doc-patch-{slug}.patch`

---

## §6 增量机制

**skill 内部决策,user 无感**:

| 决定 | 触发 |
|---|---|
| **增量 review** | 找到上次 audit 尾巴(`extract-audit-tails.sh` 输出非空) **+** 距上次跑 < 14 天 |
| **Full review** | 没 audit 尾巴 **或** 距上次 ≥ 14 天 |

**关键原则**:

- **不记 user 判断** —— user 弃掉的 surface 下次还会出现(可能 user 重新判)。这是设计,不是 bug。
- **记 skill 自己跑过什么** —— 知道上次 surface 了哪些事 / 现在作者改了哪些 file
- **正向信号** —— skill 能 surface "上次提的 X 作者已修复",作为正向 reinforcement(用 🟢 kind=positive)

**14 天阈值**:超过 14 天 PR 大概率有重大变化,full review 比增量更稳。

**escape hatch**(不显式公告):user 想强制 full?手动从 PR 删除 audit comment,下次 skill 就 full。

---

## §7 输出形式

### 终端报告 —— 核心设计原则

**user 在终端必须一眼看到 4 件事**(不需要 cat draft 才知道):

1. **一句话判断** —— 这个 PR 整体什么情况
2. **建议你做的事** —— 明确的下一步动作 + 理由
3. **评论预览** —— skill 准备替你发什么(开头 5-10 行)
4. **surface 统计** —— 数量级感知

设计意图:让 user 在终端 30 秒决定"是直接 publish 还是先 cat 完整 draft 微调"。

### `/pr-review #N` 模式终端报告 format

```
═══ PR Review Report ═══

📌 PR #194 / 作者 Yennfe
   feat(file-preview): Phase 2 docx 渲染器(截图痛点闭环)

💬 一句话判断
   docx 渲染做得很完整,9 文件 +364 行干净加法,baseline 全过,可以直接合。

🎯 建议你做的事:✅ 直接 merge + 留致谢评论
   理由:核心功能完整 / 测试覆盖 / 0 阻塞 / Phase 3 启动信号就位

📝 准备替你发的 PR 评论(开头预览):
─────────────────────────────────────────
✨ docx 渲染这版做得很完整,可以直接合。

具体识别(3 处做得真漂亮):

1. mammoth 用"用户打开 docx 才加载",首次启动包大小没受影响
2. 失败 fixture 三类齐全(损坏 / 加密 / 超大),边界 case 覆盖到了
3. ...
─────────────────────────────────────────
   完整 draft:cat ~/.pr-review-drafts/pr-194-comment.md
   一键发布:bash scripts/publish.sh #194

📊 surface 统计
   🔴 阻塞:0   🟡 应改:1   🟢 观察:3(含 2 个正向)

📂 已生成 draft:
   - pr-194-comment.md           (PR 评论:致谢 + 1 🟡 + 3 🟢)
   - pr-194-issue-phase-3-prep.md (Phase 3 启动前的 1 件准备工作)
```

### 建议动作枚举(5 种)

LLM 根据 surface 情况选 1 个,不要发明新动作。**注意:merge 永远配致谢评论,不存在"无需评论"档**(详见 §5.1 高质量致谢提示词)。

| icon | 动作 | 触发条件 |
|---|---|---|
| ✅ | **Merge + 致谢评论(必有致谢)** | 0 🔴 阻塞;🟡 应改事项可以延后到 follow-up issue / 后续 PR |
| 🟡 | **评论要求作者完善后再 merge** | 有 🟡 应改事项必须在本 PR 内改完(eg 启动信号缺一环 / 关键 stub 没标注) |
| 🔴 | **阻塞,等作者改完重审** | 有 🔴 阻塞事项(违反 DNA / 严重隐性破坏 / 回归测试破) |
| ⏸ | **暂缓拍板,需要 user 自己判断** | 设计层面的事 skill 拍不准(架构选型 / 战略方向 / 哲学优先级) |
| ❌ | **建议关闭这条 PR** | 方向错了 / 重复别的 PR / 已被新设计取代 |

**"建议动作"必须给具体理由**,不是空判定。Eg:

- ✅ 不写"approve",写"Merge + 致谢评论,理由:0 阻塞 + Phase 3 启动信号就位 + 契约测试覆盖完整"
- ❌ 不写"需要修改",写"评论要求作者补 mammoth 打包命名后再合,理由:不补的话 Phase 4 排查会绕路"

### 评论预览 component

预览**开头 5-10 行**,够 user 感知"语气是不是对路 / 重点抓得对不对"。

预览**必须包含**:
- 一句话整体评价(白话,不是术语)
- 至少 1 个"具体识别"或者 surface 标题(让 user 知道 skill 准备说哪些事)

预览**不需要**完整 surface 列表(那是 draft 文件的事)。

### `/inbox` 模式终端报告 format

```
═══ Inbox Report ═══

✅ 建议直接合 (2 个 PR):
   #198 /api/raw 100MB 流式测试 — 0 surface,致谢即可
   #199 Windows CI runner — 0 surface,致谢即可

🟡 需要你拍板 (3 个 — 已深度审 + 生成 draft):
   #194 Phase 2 docx        — 1 🟡 / 2 🟢 — 建议直接 merge + 致谢
   #197 Phase 3 xlsx + ipynb — 2 🟡 / 1 🟢 — 建议要求补一项再 merge
   #189 prompt 修正         — 1 🔴       — 建议阻塞,等作者改完重审

⏳ 待 CI / 等作者 (4 个):
   #111 / #136 / #178 / #191

📂 已生成 6 份 draft,bash scripts/publish.sh #N 一键发
```

**关键差异 vs `/pr-review #N` 模式**:inbox 是横向盘点,每个 PR 给一句话 + 建议动作即可,不嵌完整预览(预览在 draft 文件里)。

### Draft 文件位置

`~/.pr-review-drafts/`:

```
pr-{N}-comment.md           # PR comment(必有,即使是 "未发现 surface")
pr-{N}-issue-{slug}.md      # Issue(发现新独立工作时才有)
pr-{N}-doc-patch-{slug}.patch  # 独立文档 patch(跨 PR 文档过时才有)
```

---

## §8 触发设计

```
/pr-review #N    深度 review 单 PR
/inbox           全 open PR 分类盘点 + 深度审"需要拍板"那类
```

**零 flag,零跳过规则,零增量参数**。

skill 内部自动决策:
- 增量 vs full(基于 audit 尾巴 + 14 天)
- Draft / 大 PR / 自己开的 PR **全审**(reviewer 是质量守门员,自己 PR 也要守门)

---

## 反模式 —— skill 设计 / 实施时不能做的事

**这部分是元层面提醒,LLM 实施 / 维护 skill 时回看**。

### ❌ 不能把语境依赖的判断硬编码进脚本

**好脚本** = 做 deterministic 的事(API 调用 / 字符串解析 / 集合运算)。

**坏脚本** = 做语义判断(如 grep 文档涟漪、判断变量名堆积、判断哪些技术词需要翻译)—— 这些是语境依赖的事,留给 LLM。

**反例**:`detect-doc-ripples.sh` 用 grep 找 PR 改的 file 在 docs 里被提到的位置 —— 文档不会用精确文件名描述代码,grep 抓不到同义概念,**漏掉真实涟漪**。已删除,改让 LLM 用 `Grep` / `Read` 工具语义搜。

### ❌ 不能给 LLM 穷举检查清单替代开放判据

**工程债嗅探**绝不列"检查项 1-4"那种清单。给 LLM 哲学锚点 + "你不限于这些"判据,让 LLM 自由发挥。

清单化的代价 = LLM 在 N 个维度里转,看不到第 N+1 类问题。

### ❌ 不能让 skill 记忆 user 判断 / 替 user 抑制 surface

**假阳性的解药是改 skill,不是压制 surface**。

如果 user 反复弃同样类型的 surface,意味着 skill 的某条判据该改。**改判据,不是给 skill 加"记忆"**。

### ❌ 不能违反白话原则却没自检

**LLM 写完每份 draft 必须自己以 clarity-first 判据再过一遍**。这一步**不能跳**,因为 LLM 默认会堆术语,只有自检才能 catch。

### ❌ 不能把 reviewer 内部判断混进 PR 评论本体(身份混乱)

**PR 评论是用 user 的 GitHub 账号发出去的,作者读到时认为是 user 本人在说话**。

任何"建宇你判断" / "请 user 拍板" / "我作为 skill 嗅探到" / "建议动作:merge + 致谢" 这类话**绝不能出现在 PR 评论里** —— 它泄露身份,作者会困惑"这评论到底是谁写的"。

**区分**:
- 终端报告 = 给 user 看的内部分析(建议动作 / surface 统计 / 评论预览)
- PR 评论 draft = 用 user 口吻直接对作者说,身份必须自洽

**实战教训**:第一版 EXAMPLES.md 写了"## skill 嗅探到的事",这就是身份泄露。后改成"## 顺带提几件事"自然口吻。

### ❌ 不能写空话致谢(merge 必须致谢且有质量)

**空话致谢比不致谢更伤** —— 它说明 reviewer 没认真读,反而打击作者下次认真做的动机。

**禁忌**:
- "辛苦了,做得很好" / "继续保持" / "整体质量很高" 单独成段
- 用形容词堆砌("非常优秀" / "极佳的代码")
- 把 🟡 缺点 wrap 上"瑕不掩瑜"伪装成正面致谢
- merge 不带致谢

**正确做法**:每条具体识别走 §5.1 ⭐ 3 要素结构(做了什么 / 为什么不容易 / 连锁好处)。即便小 PR(改 typo / 升 dep)也至少识别一处具体的事。

### ❌ 设计 prompt 时默认倾向穷举(元层面留痕)

skill 设计 / 迭代时,**默认倾向会是"列出 LLM 可能要做的所有事"** —— 这恰好违反 A18 薄协议厚智能。

实证教训:本 skill grill 期间 reviewer 反复 catch 同一错误:

- 工程债嗅探最初列了 4 项检查 → reviewer 校准为"开放判据 + 哲学锚点"
- 假阳性收敛最初给 3 个选项铺满 → reviewer 校准 framing 本身错
- 反模式归纳最初给完整 prompt 模板 + 输出格式 → reviewer 校准"只做抽象提示词引导"
- 输入侧结构化最初推方案 B 多文件抽屉 → reviewer 校准让 LLM 做分类决策违反 A37

**判据**:写完任何 prompt 加法后,回看 ——
"我能不能用'你自由判断'四个字代替这 N 行?"

- 能 → 这 N 行是穷举陷阱,改简
- 不能 → 这 N 行是真锚点不是清单(eg 致谢 3 要素是真锚点 —— LLM 默认会写空话,不能"自由判断"代替)

**列得越具体,LLM 在那 N 个维度里转就越深,看不到第 N+1 类问题**。
