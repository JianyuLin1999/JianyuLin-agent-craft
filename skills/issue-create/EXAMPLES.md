# issue-create 真实场景的完整例子

落地到真实场景的完整 sample。让你回看这个 skill 时能"看见" 草稿到底长什么样、终端跑起来什么感受。

---

## 场景:user 脑暴 "ipynb 渲染应该考虑 cell tag 过滤" → 跑 `/issue-create`

### 终端从头到尾长什么样

```
你: /issue-create ipynb 渲染应该考虑 cell tag 过滤

skill:
[跑 fetch-issue-context.sh "ipynb 渲染应该考虑 cell tag 过滤"]
[内部:多想法识别 + 重复检测 + template 路由 + codebase 调研]

═══ Issue Create — 解析结果 ═══

📋 我看到 1 个想法,综合分析如下:

   想法 1:ipynb 渲染应该考虑 cell tag 过滤
   ├ 模板:PRD / 方案草案
   │       (因为你给了"过滤 cell tag"这个方向,语态像"我建议做 X")
   ├ 疑似重复:
   │   - #155 文件预览格式支持矩阵(父 issue,讨论过 ipynb 渲染)
   │   - #193 file-preview Phase 1 follow-up(提过 fileSize 接入)
   ├ codebase 调研 highlight:
   │   - 找到 `notebook-renderer.tsx` 已经在读 `cell.tags`(L142)
   │   - `cell.ts` 里 `Cell.tags` 类型是 `string[]`,现有 tag 枚举有 hidden / output / metadata
   │   - 没找到任何现有过滤逻辑 — 这是个真新增,不是修改
   └ 建议:看一眼 #155 是否已包含本想法。如未包含,继续 grill 4-5 题(prd 模板)

❓ 你想怎么处理?
   (1) 继续 grill,建立独立 issue
   (2) 看完 #155 决定再说(请 abort,我先 gh issue view 155)
   (3) 合并进 #155 评论(不开新 issue)
   (4) 重新输入

请选 (1/2/3/4):

你: 1

skill:
═══ Grill (PRD 模板,4-5 题)═══

我现在开始追问,帮你把这个想法收敛成完整 PRD。我刚才扫了 codebase 一遍,几个问题带着代码里看到的事实问你。

**Q1**:你提到"过滤 cell tag",我在 `cell.ts` 里看到 `Cell.tags` 类型是 `string[]`,现有枚举有 hidden / output / metadata 三种。具体哪些 tag 该被过滤?
我的推荐:先做 `hidden` tag 这个最常见的(MVP),其他 tag 留作后续 phase。

你: 对,先做 hidden tag。但是研究用户可能用自定义 tag(eg "draft"、"sandbox")标记调试 cell,可能也要支持

**Q2**:研究用户怎么知道有 cell 被隐藏了?完全静默隐藏会让用户困惑"为什么我的某些代码不见了"。
我的推荐:在预览顶部显示一行"3 个 cell 被隐藏(tag: hidden, draft),点击展开",轻量但 visible。

你: 同意你的推荐,但是默认折叠,不要展开按钮太显眼,简单的小三角形指示就够

**Q3**:范围 — 这个改进是要做成"用户可配置"(每个用户自己设置过滤规则)还是"全局固定规则"(所有用户看到一致行为)?
我的推荐:MVP 用全局固定(过滤 hidden + draft 两类 tag),后续 phase 如果有需求再做用户可配置。

你: 同意 全局固定 不做可配置

**Q4**:备选方案 — 除了"过滤隐藏"还考虑过哪些方向?eg 折叠所有 cell 默认收起,user 按需展开;或者按 cell type 过滤(只显示 markdown cell)。
我的推荐:我倾向"过滤隐藏"而非"折叠收起",因为研究用户大多想看完整 cell 顺序,只是排除明显是调试用的。

你: 我也觉得过滤隐藏更好 但是再加一个 - 如果整个 notebook 没有任何被过滤的 cell 那就不显示提示行 减少视觉干扰

**Q5**:验收 — 怎么算这个 PRD 完成?
我的推荐:3 条 — (a) hidden + draft tag 的 cell 在预览中不显示 (b) 顶部有可见提示行带计数 (c) 全 notebook 无过滤时不显示提示行。

你: 同意

[grill 结束,LLM 整理 + 写 draft + 自检]

═══ Issue Create Report ═══

📌 已生成 issue draft

   想法 1:[PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容
   ├ 模板:PRD / 方案草案
   ├ 字段:8/8 已填(0 🚧,含 Background)
   ├ Slug:ipynb-preview-cell-tag-filter
   └ Draft:~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md

📝 准备发布的 issue title 预览:
─────────────────────────────────────────
[PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容
─────────────────────────────────────────

下一步:
   cat draft:cat ~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md
   一键发布:bash scripts/publish-issue.sh ipynb-preview-cell-tag-filter

你: [cat 一眼,确认 draft 内容 OK]
你: bash scripts/publish-issue.sh ipynb-preview-cell-tag-filter

skill:
═══ 发布单个 issue ═══
  → 创建:[PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容
    ✓ https://github.com/jianyulin/Sedna/issues/220
```

---

## 生成的 Draft:`~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md`

````markdown
---
title: "[PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容"
template: prd-proposal
labels: ["prd", "needs-review"]
placeholder: false
generated_by: issue-create
generated_at: 2026-05-21T01:35:00Z
---

# [PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容

## Background — 我调研到的现有代码

> (本字段由 issue-create skill 调研产出,第三人称视角,跟 user 主观字段视觉分开)

- `notebook-renderer.tsx` L142 已经在读 `cell.tags`,但没做过滤,直接全部渲染
- `cell.ts` 定义 `Cell.tags: string[]`,现有 tag 类型枚举:hidden / output / metadata
- 没找到任何现有 tag-based 过滤逻辑 — 这是真新增,不是修改现有路径
- 父 issue #155 提到过 ipynb 渲染整体方向,但没具体讨论 cell tag 过滤

## 人话摘要

我建议 ipynb 预览支持按 cell tag 过滤隐藏调试内容(`hidden` 和 `draft` 两种 tag),
因为研究用户常常打开 100+ cell 的 notebook,但其实只想看分析结果,
被混在其中的调试 cell / sandbox cell 干扰阅读。先做全局固定规则(MVP),后续 phase 再考虑用户可配置。

## 要解决的问题

我作为研究用户打开 ipynb 预览时,看到所有 cell 平铺展示,包括我自己当初标记为 hidden 或 draft 的调试 cell。
这些 cell 是我开发时用来快速验证的内容,不应该出现在最终的预览中 —— 但目前预览没有过滤,
导致 100+ cell 的 notebook 里夹杂了大量调试 cell,我需要肉眼跳过这些 cell 才能找到分析主线,
阅读效率明显下降。

## 推荐方案

过滤 `hidden` 和 `draft` 这两种 cell tag,在 ipynb 预览渲染时直接不显示带这些 tag 的 cell。

视觉提示:如果有 cell 被过滤,在预览顶部显示一行小提示
"3 个 cell 被隐藏(tag: hidden, draft)",默认折叠状态用一个小三角形指示可展开。
**如果整个 notebook 没有任何被过滤的 cell,不显示这行提示**,减少无意义的视觉干扰。

## 范围

做:
- 过滤 `hidden` 和 `draft` 两种 tag 的 cell(全局固定规则)
- 顶部可见的"N 个 cell 被隐藏"提示行,默认折叠
- 全 notebook 无过滤时不显示提示行

暂缓:
- 用户可配置过滤规则(每个用户自定义)
- 按 cell type 过滤(eg 只显示 markdown cell)
- 折叠收起所有 cell 让用户按需展开

## 代价和风险

我目前能想到的代价和风险:

- **学习曲线**:研究用户第一次看到"3 个 cell 被隐藏"提示时,可能困惑"什么是 hidden tag / 我什么时候打的 tag"。需要在文档里解释 cell tag 概念,但不阻塞 MVP。

(我在 grill 中没有深入讨论其他风险,以下字段如有需要可在后续 PRD review 时补充。)

## 备选方案和取舍

我考虑过:

- **折叠收起所有 cell,用户按需展开** —— 暂不采用,因为研究用户大多想看完整 cell 顺序,只是排除明显是调试用的;折叠收起会让阅读节奏变笨。
- **按 cell type 过滤(eg 只显示 markdown cell)** —— 暂不采用,因为完全过滤掉 code cell 会让分析过程不可见,违反研究用户"看分析过程"的核心诉求。

最终推荐"过滤带特定 tag 的 cell"这个方向,因为:
- 用户控制权:user 当初打 tag 就是想标记"这是调试用的"
- 视觉简洁:跳过明显的调试 cell,主线清晰
- 不破坏完整性:绝大部分 cell 仍然显示

## grill-me 存档

**Q1(LLM)**:你提到"过滤 cell tag",我在 `cell.ts` 里看到 `Cell.tags` 类型是 `string[]`,现有枚举有 hidden / output / metadata 三种。具体哪些 tag 该被过滤?

**A1(我)**:对,先做 hidden tag。但是研究用户可能用自定义 tag(eg "draft"、"sandbox")标记调试 cell,可能也要支持

**Q2(LLM)**:研究用户怎么知道有 cell 被隐藏了?完全静默隐藏会让用户困惑"为什么我的某些代码不见了"。

**A2(我)**:同意你的推荐,但是默认折叠,不要展开按钮太显眼,简单的小三角形指示就够

**Q3(LLM)**:范围 — 这个改进是要做成"用户可配置"还是"全局固定规则"?

**A3(我)**:同意 全局固定 不做可配置

**Q4(LLM)**:备选方案 — 除了"过滤隐藏"还考虑过哪些方向?

**A4(我)**:我也觉得过滤隐藏更好 但是再加一个 - 如果整个 notebook 没有任何被过滤的 cell 那就不显示提示行 减少视觉干扰

**Q5(LLM)**:验收 — 怎么算这个 PRD 完成?

**A5(我)**:同意

## 什么算完成

- [ ] `hidden` 和 `draft` tag 的 cell 在 ipynb 预览中不显示
- [ ] 预览顶部有可见提示行 "N 个 cell 被隐藏(tag: ...)",默认折叠
- [ ] 全 notebook 无过滤时不显示提示行
- [ ] cell tag 概念在 docs/install 或类似位置有简短解释
````

**为什么这份草稿长这样** — 全程用 user 第一人称("我作为研究用户..." / "我考虑过..."),GitHub 自动把 frontmatter 之外的 markdown 渲染成 issue body,Yennfe 或者三个月后的 user 自己打开看,都会觉得这是 user 本人在写。第三人称("user 说" / "skill 整理")一漏出来,信任感立刻崩。

---

## 对比:同样输入跑 `/issue-capture`(快速占位模式)

```
你: /issue-capture ipynb 渲染应该考虑 cell tag 过滤

skill:
[跑 fetch-issue-context.sh "ipynb 渲染应该考虑 cell tag 过滤"]
[内部:多想法识别 → 1 想法 + 自动 template 路由 → PRD,跳重复检测]
[整理 user 原始输入 → 写 draft,跳 grill]

═══ Issue Capture Report ═══

📌 占位 issue draft 已生成:
   标题:[PRD] ipynb 渲染应该考虑 cell tag 过滤
   模板:PRD / 方案草案(自动 route)
   字段:3/8 已填(5 个 🚧 待 grill 补完,Background 浅扫了 2 个文件)
   Slug:ipynb-cell-tag-filter-placeholder
   
   完整 draft:cat ~/.issue-drafts/issue-ipynb-cell-tag-filter-placeholder.md
   一键发布:bash scripts/publish-issue.sh ipynb-cell-tag-filter-placeholder

💡 后续升级路径:
   - 现在:bash scripts/publish-issue.sh ipynb-cell-tag-filter-placeholder
   - 升级:/issue-create #N(N 是 publish 后拿到的编号)→ grill 后填上 🚧 字段
```

### Capture 模式生成的 Draft

````markdown
---
title: "[PRD] ipynb 渲染应该考虑 cell tag 过滤"
template: prd-proposal
labels: ["prd", "needs-review", "placeholder"]
placeholder: true
generated_by: issue-capture
generated_at: 2026-05-21T01:35:00Z
---

# [PRD] ipynb 渲染应该考虑 cell tag 过滤

## Background — 我快速调研到的相关代码

> (capture 模式只列文件路径,grill 升级时再深入 Read)

- `notebook-renderer.tsx`(可能是渲染入口)
- `cell.ts`(可能定义 Cell 类型)

## 人话摘要

我建议 ipynb 渲染时应该考虑 cell tag 过滤。

## 要解决的问题

🚧 待 grill 补完

## 推荐方案

我提到"过滤 cell tag",但还没说清楚具体过滤哪些 tag / 怎么呈现给 user。
🚧 待 grill 补完

## 范围

🚧 待 grill 补完

## 代价和风险

🚧 待 grill 补完

## 备选方案和取舍

🚧 待 grill 补完

## grill-me 存档

🚧 待 grill 补完(本 issue 是 capture 模式产出,跑 `/issue-create #<本 issue 编号>` 升级)

## 什么算完成

🚧 待 grill 补完
````

**create 和 capture 在产物上的关键差异**:
- capture 只把 user 原始输入归到"人话摘要" / "推荐方案" 字段(因为这些是 user 说过的)
- 其他主观必填字段全 🚧
- frontmatter `placeholder: true` + 自动加 `placeholder` label
- grill-me 存档字段也是 🚧,等升级时填
- Background 字段也填,但只列文件路径 — capture 只做快速 grep 不深入 Read,grill 升级时才深入

**为什么这么设计** — capture 的定位就是"低质量占位",user 选 capture 的那一刻就接受了这个交易。Background 即便只列几个文件路径,后期升级时也有 jumpstart 价值,user 自己 review 时也能快速验证这个想法关联到哪几个文件。等她有空回来跑 `/issue-create #N` 升级,那时候才做深度 codebase 调研 + grill + 把所有 🚧 字段填上。

---

## 场景:升级占位 → `/issue-create #220`

假设 user 上周 `/issue-capture` 出 #220 占位,现在想升级:

```
你: /issue-create #220

skill:
[跑 fetch-issue-context.sh --upgrade 220]
[拿到 #220 的 body 当 grill 起点 + 开始 codebase 调研]

═══ Issue Create — 升级模式 ═══

📋 拉取占位 issue #220:
   标题:[PRD] ipynb 渲染应该考虑 cell tag 过滤
   现状:placeholder=true,5/8 字段 🚧(Background 当初只列了 2 个文件,我会再深入 Read)
   user 当初记录:"我建议 ipynb 渲染时应该考虑 cell tag 过滤"
   
我会从这个起点 grill 4-5 题(PRD 模板),完整化字段。开始?(y/N):

你: y

[skill 跑跟前面一样的 grill 流程 — 带 codebase 调研证据问]
[整理后写 draft,frontmatter 标 upgrade_target: 220]

═══ Issue Upgrade Report ═══

📌 已生成升级版 draft

   原 issue:#220 [PRD] ipynb 渲染应该考虑 cell tag 过滤
   现 draft:ipynb-preview-cell-tag-filter
   字段:8/8 已填(0 🚧,Background 深入 Read 重写)
   placeholder label 准备移除

📝 升级 issue 命令:
   gh issue edit 220 --body-file ~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md \
     --remove-label placeholder
   
   (注:publish-issue.sh 当前只 handle create,upgrade 模式短期用 gh CLI 手动)
```

---

## 实际跑下来 user 花多少时间

如果 user 走这套流程开一个 PRD issue,耗时大概:

```
$ /issue-create ipynb 渲染应该考虑 cell tag 过滤
[skill 拉 context + 解析 ~15 秒]
[skill 主动 grep + Read 调研 codebase ~30-60 秒]

[user 看综合报告 + 选 1 ~30 秒]

[skill grill 5 题(每题带 codebase 证据),user 回答 ~5 分钟]

[skill 整理 + 写 draft + 自检 ~30 秒]

$ cat ~/.issue-drafts/issue-ipynb-preview-cell-tag-filter.md
[user 审 draft ~1 分钟]

$ bash scripts/publish-issue.sh ipynb-preview-cell-tag-filter
[发布 ~5 秒]

总耗时:~7-9 分钟
```

对比 "user 自己写 PRD" 耗时:**20-30 分钟**(找模板 + 想清楚每个字段 + 自己 grep 代码 + 写人话摘要 + 写 grill 存档 + 反复修)。

**3-4 倍效率提升**,而且 issue 质量更高:
- grill 强制 stress-test,user 不会糊弄过去
- 模板必填字段不漏(没填的就是 🚧,显式留白)
- grill 存档自动留全文
- Background 字段帮 user 把 codebase 现状写出来,协作者读 issue 就拿到上下文,不用再 grep 30 分钟

---

## 回看这份例子时记几条

1. **不脑补 = 每个 user 主观字段要么有 user 实际说过的内容,要么 🚧** — 不允许编"通用风险" / "标准学习曲线" 这种万能套话
2. **但 codebase 调研出来的事实不算脑补** — 那些走 Background 字段,用第三人称,跟 user 主观字段视觉分开
3. **user 口吻 = 第一人称写整个 body** — 不能出现 "user 说" / "skill 整理"(Background 字段例外)
4. **grill 存档存全文,不存摘要** — Sedna 模板要求 + 3 个月后回看时全文比摘要值钱得多
5. **多想法时 create 询问 user / capture 自动拆** — 两个 skill 的 trade-off 不同,行为故意不同
6. **重复检测软提醒,不挡路** — user 自己有决策权,skill 只把发现的点摆出来
7. **草稿闸口两个 skill 都走** — capture 不直接发是因为自动整理失真概率高,不脑补这条线需要 user verify 一眼
8. **升级路径用同一个 skill(`/issue-create #N`)** — create 的本质是"拿初始信息收敛成完整 issue",不是"从无到有",所以占位升级也走 create
