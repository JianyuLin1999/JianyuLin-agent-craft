# issue-review REFERENCE

完整规则。SKILL.md 是 quick start,这里是细节。

设计哲学跟 pr-review / issue-create 一脉相承 — clarity-first / 零脑补 / user 口吻 / 默认严苛 / 开放判据。

---

## §0 设计根原则

### 0.1 评估对象是"想法 + 文字",不是"代码 diff"

Issue 是 ambiguous 想法(可能没完成 / 可能不清楚),不是 deterministic 产物。所以评估维度比 pr-review 更聚焦"内容质量"(clarity / 完整度 / 可执行性)而非"代码 ripple"。

### 0.2 质量 >> token 成本

fetch context 全量拉(目标 issue + 全部 open + 项目方向文档全文),不为省 token 牺牲精度。

### 0.3 零脑补硬约束(继承自 issue-create)

LLM 在 draft 评论里只能引用 issue 实际内容 + 项目实际文档,不能编"通用建议" / "标准做法"等套话。

### 0.4 User 口吻 + 身份自洽(继承自 pr-review)

评论用建宇第一人称对作者说,**严禁泄露 skill 身份**。

### 0.5 评论语言纪律(共享,跨 skill 单源)

写 draft 时遵循 [`knowledge-assets/comment-voice.md`](../../knowledge-assets/comment-voice.md) —— 三条核心原则 + 两个对立失败模式 + 致谢要能指着东西 + 不替对方想 + 字数和密度 + 8 条自检。**跨 pr-review / issue-review 共享单源**。

最关键的洞察(常错):
- **说事实,别评价人**:正确中间地带是只说事情,不评价对方
- **给选择,别下命令**:把决定权还给对方
- **不替对方想**:不预测对方反应 / 不替对方找借口 / 不替对方切活 / 不替对方估工作量

---

## §1 5 维度评估细则

每条 issue 跑 5 维度评估,**LLM 用语义判断**(不靠脚本 grep 关键词)。

### A. Clarity — 说人话吗?

**判定根基**:作者(协作者 / 3 个月后的 user 自己)地铁手机读,每段 30 秒读懂"这是什么 / 为什么 / 该做啥"。

**典型失败形态**:
- 标题 / body 堆英文技术词 / 文件路径 / 变量名
- "人话摘要"字段实际是 git commit message 风格("feat: add X")
- 推理链跳步(eg "因为 A 所以 D",中间 B 和 C 消失了)

**典型通过形态**:
- 标题白话(eg `[PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容`)
- 正文有具体场景描述("我作为研究用户打开 100+ cell 的 notebook,看到所有 cell 平铺...")
- 文件路径独立成"位置:"行(不混在正文)

### B. 完整度 — Sedna template 必填字段填满吗?

**判定根基**:对照该 issue 的 template(bug-report / prd-proposal / project-gap)的必填字段清单,逐个 check。

**典型失败形态**:
- 字段值是 `🚧 待 grill 补完`(placeholder issue 常见)
- 必填字段空着(template 强制但作者没填)
- 必填字段被"填了字但等于没填"(eg "TBD" / "暂无" / "稍后补")

**典型通过形态**:
- 所有必填字段实际填了 user 说过的话
- grill-me 存档完整(prd / gap 模板强制)
- bug 模板有 bundle + 截图 + 重现步骤

### C. 唯一性 — 跟现有 open + closed 重复吗?

**判定根基**:LLM 用语义判断,**不靠 grep**(同义概念 grep 抓不到 — eg "渲染" vs "预览" 是同一件事)。

**典型失败形态**:
- 跟某个 open issue 完全是同一件事(应该合并)
- 跟某个 closed issue 是同一件事(已被解决,应该 reopen 或 close 当前)
- 跟某个 placeholder 重复(应该升级而不是新开)

**典型通过形态**:
- 主题在 open / closed 都找不到相似对象
- 跟相关 issue 有关联但**不是重复**(eg 是父 issue / 子 issue / 横向相关)

**注意**:跟 issue-create 的"重复检测"区别 —
- issue-create 重复检测:**事前**,避免重复创建
- issue-review 唯一性维度:**事后**,catch 已经创建的重复

### D. 可执行性 — 有清晰下一步吗?

**判定根基**:任何读者(包括 3 个月后的自己)读完能知道"接下来该做什么 / 怎么算完成"。

**典型失败形态**:
- 没"建议下一步"字段(gap 模板必填)
- 验收标准模糊(prd 模板要求 3-7 条可检查)
- 描述只到"我看到一个问题",没说"我建议..."或"怎么算解决"

**典型通过形态**:
- 验收标准用 `[ ]` checkbox 列具体可验证条件
- bug 模板有明确"期望行为"对照"实际行为"
- prd 模板"什么算完成"列了 3-7 条

### E. 跟项目方向一致 — 跟 PRD / plan / 哲学对齐吗?

**判定根基**:LLM 拿到 fetch context bundle 里的 PRD / plan / 哲学母版,做语义对齐判断。

**典型失败形态**:
- 跟某 PRD 的 "v1 不做 X" 显式声明冲突
- 跟当前 plan 的 phase 范围越界
- 重新发明已存在的功能(没看见已有方案)
- 跟某哲学原则冲突(eg PRD 写"避免 LLM 临场推理",但 issue 提议"LLM 临场生成 X")

**典型通过形态**:
- 引用了相关 PRD / plan(eg "对应 docs/prd/file-preview.md §3.2")
- 在已有 phase 边界内
- 跟项目哲学一致(eg "符合哲学里'活文档'的精神,代码改了文档也跟着改")

### 5 维度跨模板分级

5 维度对所有 issue 都跑,但**每种 template 重点不同**(LLM 自由判断,不写死):

- **bug**: B 完整度(bundle / 重现步骤) + D 可执行性(期望明确)是重点
- **prd**: A clarity + B 完整度(代价 / 备选) + E 项目方向是重点
- **gap**: A clarity + D 可执行性(建议下一步)是重点

### 维度结果用三档 icon

| icon | 含义 |
|---|---|
| ✅ | 该维度通过 |
| 🟡 | 该维度有问题,应该改 |
| 🔴 | 该维度严重失败,阻塞推进 |

类比 pr-review 默认严苛 — 不要为了让 issue 通过而把 🟡 降成 ✅。

### 1.6 7 维度 deterministic 盲点扫描(5 维度的兜底)

5 维度评估靠语义判断会**阈值漂移**。这 7 维是机械扫描 —— 跑完 5 维度后必须再过一遍,catch 阈值漂移会跳过的 nit:

| 维度 | 怎么扫 | 典型 surface |
|---|---|---|
| **① 描述精确度** | grep 模糊词:"等" / "之类" / "可能" / "类似" / "比较 X" / 形容词无量纲(快 / 慢 / 大 / 小);看作者是否说"做某某功能"但没说具体边界 | "改进 captain 表现" 没说改什么 / 怎么算改进了 |
| **② 跟现有 open / closed 重复** | 拿 issue 标题 + 关键词 grep open issues + 90 天 closed + open PR 标题。任何文字重叠 > 30% 必须 surface | "支持 xlsx 预览" 跟 closed #155 重复 |
| **③ Sedna template 必填字段** | 检查 template(bug / prd / gap)定义的必填字段,有没有 🚧 占位 / 空 / 一句话敷衍 | bug 模板"重现步骤"只写"打开就崩" → 信息不足 |
| **④ 验证标准 / 成功判据** | grep "如何验证" / "怎么算完成" / "成功标准";没有就 surface | PRD 没写"做完后怎么判断它有效" → 永远做不完 |
| **⑤ 项目方向潜在冲突** | 拿 issue 标题关键词 grep `docs/prd/` 现有 PRD / `docs/philosophy/` 哲学原则,看有没有反方向 | "用户管理 mamba 环境" 跟 A27 "障碍消除默认" + Q5 pivot "Agent autonomy default" 冲突 |
| **⑥ Scope 大小** | 看 issue 描述长度 / 涉及模块数 / 跨多少 phase。> 3 模块或 > 1 个 sprint = 该拆;< 5 行描述且单文件 = 可能可合到现有 issue | PRD 横跨 6 个模块 = 应该拆成 6 个子 issue |
| **⑦ 实证 gap** | bug 类:有没有附 bundle / repro / 截图 / log;PRD 类:有没有附 design doc / mockup / RFC link;gap 类:有没有附"看到的现象" | bug 只写文字描述没附 log → 复现要走访谈 |

**怎么用**:跑完 5 维度评估后,**按这 7 维度各跑一遍**,任何命中进 surface 候选池,挂严重度。

### 1.7 心理基线 + 0 nit 强制反思

#### "至少 3 个可改进点" 心理基线

任何 issue 在没找到至少 3 个 surface 之前**都不算审完**。给 ✅ Approve 前必须过这条。

**例外**:极端短小的 issue(如纯 chore / dup-of-#N close request)可以 < 3,但必须先过 0 nit 反思。

#### 产出 0 nit 时强制反思 3 条

1. **我有没有用"作者写得很完整"借口跳过?**
   - 反例:"template 字段都填了,看上去都好"
   - 正确:字段填满 ≠ 内容到位。完整度只是 1 个维度,verify 其他 6 个维度真的都过了吗
2. **我有没有用"主题听上去合理"借口跳过?**
   - 反例:"PRD 写得很专业,方向也对"
   - 正确:方向合理 ≠ 这个 issue 本身充分。issue 是 issue,方向是方向
3. **我有没有用"5 维度都过了"借口跳过?**
   - 反例:"5 维度评估全过,没什么可挑的"
   - 正确:5 维度是 baseline 不是天花板。回去把 §1.6 7 维全跑一遍

3 条都过 + 7 维全扫过 = 真 0 nit。否则补 surface。

---

## §2 5 种建议动作 + 致谢机制

### 2.1 建议动作枚举(同 SKILL.md)

| icon | 动作 | 触发 |
|---|---|---|
| ✅ | Approve & 致谢评论(等推进) | 5 维度全过(或只有 🟢) |
| 🟡 | 评论要求作者完善 | 某维度 🟡 |
| 🔧 | 建议升级 / 拆分 / 合并 | placeholder 该升级 / 太大该拆 / 重复该合 |
| ⏸ | 暂缓,需要 user 拍板 | 方向选型 / 战略 / 哲学优先级 |
| ❌ | 建议关闭 | 重复 / 过时 / 错误方向 / 已解决 |

### 2.2 ⭐ 高质量致谢提示词(approve 必须致谢)

**核心目标**:让作者感受到"我的想法被精确看见了"。Approve 不带致谢 = 暗示 reviewer 没认真读,**比不致谢更伤**。

#### 每条具体识别必须包含 3 要素

1. **这个 issue 抓到了什么**(用具体名词命名 issue 真正解决的问题,不是泛泛"提了个建议")
2. **为什么这件事被 catch 不容易**(原本可能怎样,user 做对了什么)
3. **这件事 catch 到后带来什么连锁好处**(对 phase / 团队 / 项目长期质量的影响)

#### 致谢的 5 个常见角度(LLM 自由选 1-3 个)

| 角度 | 适用场景 | 例子 |
|---|---|---|
| **insight 角度** | 触及关键问题 | "你看到的这个问题其实是 file-preview 整体策略的一环" |
| **clarity 角度** | issue 写得清晰 | "你这个 issue 一读就懂,'人话摘要'写得很到位" |
| **完整度角度** | template 字段全 | "字段都填全了,grill 存档也在,后续 triage 节奏会快很多" |
| **timing 角度** | 早期发现 | "提前 catch 这个问题,Phase 4 启动前刚好有时间消化" |
| **抗惰性角度** | 主动发起 issue | "这种'好像可以但好像也无所谓'的需求容易被压在心底,你显式提出来值得肯定" |

#### 对比示范

❌ **空话致谢(永远不能这样写)**:
> "好建议,赞同。"
> "这个问题确实值得关注。"
> "辛苦了,继续保持。"

→ 作者读完毫无"被看见"的感觉。这种致谢比不致谢更伤。

✅ **高质量致谢**:
> 你这条 issue 抓到了一个研究用户的真实痛点 ——"想看分析主线但被调试 cell 干扰"。
> 这种需求在普通工程视角下容易被压在心底("毕竟可以滚动跳过"),但你显式提出来 + 给出"过滤 hidden + draft tag"的具体方向,后续 Phase 4 启动 ipynb 渲染时**直接有方案可落地,不需要再 grill 一轮**。

→ 命名了具体痛点 + 解释为什么这事容易被忽略 + 连锁好处。

#### 严禁(继承 pr-review)

- ❌ 空话致谢("好建议" / "辛苦了")
- ❌ 形容词堆砌("非常优秀的想法")
- ❌ 把 surface 的事 wrap 上"瑕不掩瑜"
- ❌ Approve 不带致谢
- ❌ 致谢和改进 surface 混着写

---

## §3 文字 format 规则

### 3.1 评论标题(用 emoji 而不是 H 标题)

评论 body 顶部用一行 emoji + 一句话整体判断,不用 markdown H1。

✅ 示例:
> ✅ **这条 issue 整体方向清晰,信息也够,可以等开 PR 推进了。**

> 🔧 **这是个 placeholder,信息只有 1/8 字段,建议先跑 `/issue-create #220` 升级再 triage。**

### 3.2 正文(继承 pr-review §4)

只用项目内已建立的概念。外部技术词全翻译,**第一次出现配白话**。

- ✅ 项目内反复用过的概念可保留:渲染器 / 沙箱 / 测试 / 注册表 / 模板字段
- ❌ 外部技术词不翻译:DOMPurify / dispatch / ReactNode / iframe sandbox

### 3.3 文件路径 / 变量名 / 函数名

**独立成"位置:"行,不混在正文**(跟 pr-review 一致):

✅ 这样:
```
渲染器外壳代码顶部有个折中注释,你提到了。

位置:渲染器外壳代码文件顶部。
```

❌ 不这样:
```
你在 `host.tsx:14-19` 顶部注释提到了折中。
```

### 3.4 Audit 尾巴(reviewer 内部用,GitHub 自动隐藏)

每条 surface 末尾贴 audit 尾巴:

```markdown
🟡 **某维度的 surface 标题(白话)**

[场景化解释]

位置:[人话描述]

—— [一句简短建议]

<!-- audit: dim=B-completeness, severity=yellow, ref=template-prd -->
```

字段:
- `dim=<A|B|C|D|E>` — 触发的维度
- `severity=<red|yellow|green>` — 严重度
- `ref=<可选,引用的 PRD / plan / 哲学条目>` — 用于追溯

**audit 尾巴用 HTML 注释,GitHub markdown 自动隐藏**,作者看不到内部 metadata,只看到白话内容。

### 3.5 DNA 编号 / 章节号禁入正文

跟 pr-review 一致:**`A14` / `§X.X` / `B7` 这类编号绝不出现在评论正文**。引用哲学时用白话原则名 + 场景描述。

---

## §4 Draft 文件结构 + frontmatter

### 4.1 文件路径

`~/.issue-review-drafts/issue-review-{N}-comment.md`

### 4.2 文件 format

```markdown
---
target_issue: 220
suggested_action: approve | request_changes | restructure | hold | close
labels_to_add: []
labels_to_remove: []
close: false
generated_at: 2026-05-24T20:40:00Z
---

[评论 body — emoji + 一句话整体判断 + 致谢/surface/建议下一步]
```

### 4.3 Frontmatter 字段语义

| 字段 | 取值 | 用途 |
|---|---|---|
| `target_issue` | issue 编号 | publish 校验跟命令参数一致 |
| `suggested_action` | `approve` / `request_changes` / `restructure` / `hold` / `close` | 给 publish + 给 user 终端报告引用 |
| `labels_to_add` | `["a", "b"]` 或 `[]` | publish 时 `gh issue edit --add-label` |
| `labels_to_remove` | 同上 | publish 时 `--remove-label` |
| `close` | `true` / `false` | publish 时是否 `gh issue close` |
| `generated_at` | ISO 时间戳 | 审计用 |

### 4.4 评论 body 结构(LLM 写)

```markdown
[emoji 判定] **一句话整体判断**

[1-2 句承接 — 用 user 口吻,eg "辛苦了,我看完整条 issue。整体方向..."]

## 具体识别(如 Approve)/ 该补的(如 🟡)/ 我的建议(如 🔧/⏸/❌)

[按 §2 致谢机制 3 要素 / 或 surface 按 §1 5 维度组织]

[每条 surface 末尾贴 audit 尾巴]

## 下一步建议

[一段白话,跟 suggested_action 对应的具体动作]
```

---

## §5 终端报告 format

### 5.1 4 个 component(类比 pr-review)

```
═══ Issue Review Report ═══

📌 #220 [PRD] ipynb 渲染应该考虑 cell tag 过滤 / 作者 jianyulin / placeholder=true

💬 一句话判断
   占位 issue 内容方向清晰但 5/7 字段 🚧,该走升级流程而不是直接 approve。

🎯 建议你做的事:🔧 建议升级 (跑 /issue-create #220)
   理由:placeholder + 字段缺 / 5 维度只有 A clarity 过

📝 准备替你发的评论(开头预览):
─────────────────────────────────────────
🔧 **这是个 placeholder,字段大部分还是 🚧,建议先升级再 triage**

辛苦了。我看了一下这条 capture 出来的占位:方向清晰
("过滤 cell tag"),但具体哪些 tag / 怎么呈现给 user / 边界 case 都还没说...
─────────────────────────────────────────
   完整 draft:cat ~/.issue-review-drafts/issue-review-220-comment.md
   一键发布:bash scripts/publish-issue-review.sh 220

📊 5 维度评估
   A. clarity:✅
   B. 完整度:🟡 5/7 字段 🚧
   C. 唯一性:✅
   D. 可执行性:🟡 无验收标准
   E. 项目方向:✅(跟 PRD #155 file-preview matrix 对齐)
```

### 5.2 评论预览的 deterministic 判据

预览 **开头 5-10 行**,够 user 感知"语气对路 / 重点抓得对吗"。

预览**必须包含**:
- 一行 emoji 整体判定(白话)
- 至少 1 个"具体识别"或"该补的"或"我的建议"的标题

预览**不需要**完整 surface 列表(那是 draft 文件的事)。

---

## §自检 — 写完每份 draft 后必做

LLM 必须用 **作者视角 + 反模式视角** 再读一遍。

### deterministic 判据(发现一条就改)

| 判据 | 容忍上限 |
|---|---|
| **脑补内容**(LLM 编了 issue 没说的) | **0** —— 删除或改成"我不确定" |
| **第三人称泄露身份**("issue 作者说" / "skill 评估到") | **0** —— 改第一人称 |
| 章节号 / DNA 编号(`§X.X` / `A14` / `0.2`)出现在评论正文 | **0** —— 用白话原则名代替 |
| 变量名 / 函数名 / 文件路径混在正文 | **0** —— 移到"位置:"行 |
| 一句话里英文技术词没翻译 | ≤ 1 个(且必须配白话括号) |
| audit 尾巴漏贴 | **0** —— 每条 surface 都贴 |
| **建议动作不是 5 种之一** | **0** —— 必须从 ✅🟡🔧⏸❌ 选 |
| **Approve 不带致谢** | **0** —— 必须有致谢 3 要素 |
| frontmatter 字段不完整 | **0** —— target_issue / suggested_action / close 必填 |

### 主观判据(LLM 自己判)

- 评论每段第一句能不能"独立成立"?(作者只读一句也明白大意)
- 推理链有没有跳步?
- 致谢有没有 3 要素结构,还是空话?
- 我给的"下一步建议"具体到能马上执行吗?

### 跨 skill 共享判据(必跑)

跑完本节判据后,**必须再跑** [`comment-voice.md §7`](../../knowledge-assets/comment-voice.md) 8 条 deterministic 判据。

核心判据摘要(完整见共享文件):
- 句子以 "你没 / 你应该 / 你必须 / 你不能" 开头 → 改成事实 + 选项
- "立刻能做的 N 件事:1. X 2. Y 3. Z" 形态 → 改成 "N 条路径选一"
- "可能是因为 / 估计是" 替对方解释 → 删除
- 预测对方反应("读完你会发现 X") → 删除
- 替对方切片("拆 N 个 PR:PR-1 X / PR-2 Y") → 改成"切法对齐后再聊"
- 比喻里对方被塑造成"小白 / 新人" → 重写让对方保持专业身份
- 收尾"先骂后哄"对比结构 → 收尾纯正向落在事实
- Approve 致谢没有具体代码 / 动作 / 文档引用 → 删
- "你这份 X 写得很详细 —— 看得出..." 客套开头 → 删除整句直接进事实

**两套自检都过才能 publish**。LLM 默认会在指控 / 委婉两个失败模式之间摇摆,共享自检是唯一闸口。

---

## §反模式 — skill 设计 / 实施时不能做的事

继承 pr-review / issue-create 的通用反模式 + issue-review 特有 3 条。

### 通用反模式(继承)

1. ❌ 不能把语境依赖的判断硬编码进脚本(5 维度评估 / 唯一性匹配 都让 LLM 做)
2. ❌ 不能给 LLM 穷举检查清单替代开放判据
3. ❌ 不能让 skill 记忆 user 判断 / 替 user 抑制 surface
4. ❌ 不能违反白话原则却没自检
5. ❌ 不能把 reviewer 内部判断混进评论本体(身份混乱)
6. ❌ 不能写空话致谢
7. ❌ 设计 prompt 时默认倾向穷举

### issue-review 特有反模式

#### ❌ 不能用 grep 做唯一性匹配

C 维度(唯一性)**必须** LLM 用语义匹配,不靠脚本 grep 关键词。同义概念 grep 抓不到(eg "渲染" vs "预览" 是同一件事但词不同)。

#### ❌ 不能跳过 E 维度(跟项目方向一致)

E 维度需要 LLM 读项目 PRD / plan / 哲学,token 成本高,**但绝对不能跳**。Sedna 项目的核心价值在于"跟方向对齐",一个跟方向冲突的 issue approve 进来,后续修复成本远大于 review 时多 token。

#### ❌ 不能让 LLM 替 user 做"是否真重复"的最终决策

C 维度发现疑似重复 → surface 候选 + 给推荐,但**最终决定权给 user**(eg 选 🔧 合并 vs 仍 approve 当独立 issue 处理)。同 pr-review 的 A37 不让 Agent 做分类决策原则。

---

## 附:跟 pr-review / issue-create 的异同

| 维度 | pr-review | issue-create | issue-review |
|---|---|---|---|
| 评估对象 | 代码 diff | 想法草稿 | 已存在的 issue |
| 核心评估 | DNA 5 + 涟漪 5 + 工程债 | (不评估,是 grill 收敛) | 5 维度评估 |
| 建议动作 | 5 种(merge / 改 / 阻塞 / 暂缓 / 关闭) | (不需要) | 5 种(approve / 改 / 升级拆合 / 暂缓 / 关闭) |
| 致谢对象 | 代码贡献(具体动作) | (无致谢概念) | 想法贡献(insight / clarity / timing 等) |
| Audit 尾巴 | ✓ | (无,因为创建不需要 audit) | ✓ |
| 自检不可跳 | ✓ | ✓ | ✓ |
| user 口吻 | ✓ | ✓ | ✓ |
| 零脑补 | ✓ | ✓(更严苛) | ✓ |

**家族共性**:都是 Sedna skill 哲学的物理载体 — clarity-first / 默认严苛 / 开放判据 / draft 闸口 / 致谢非空话。
