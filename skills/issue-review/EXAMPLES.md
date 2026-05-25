# issue-review EXAMPLES

应用到真实场景的完整 sample。让你回看 skill 时能"看见" draft 长什么样。

---

## 场景 1:Review 一个 Approve 类的 issue(高质量)

假设有 #220 PRD issue,经过完整 grill 后内容详尽,5 维度全过。

### 终端流程

```
你: /issue-review #220

skill:
[跑 fetch-issue-review-context.sh 220]
[LLM 跑 5 维度评估]

═══ Issue Review Report ═══

📌 #220 [PRD] ipynb 预览应该按 cell tag 过滤隐藏调试内容
   作者:jianyulin / 状态:open / placeholder=false / 创建:3 天前

💬 一句话判断
   这是一个研究用户痛点驱动的方向清晰 PRD,5 维度全过,可以直接 approve 等开 PR 推进了。

🎯 建议你做的事:✅ Approve + 致谢评论(等推进)
   理由:5 维度全过 / 跟 PRD #155 file-preview matrix 对齐 / 验收 4 条具体可检

📝 准备替你发的评论(开头预览):
─────────────────────────────────────────
✅ **这条 PRD 方向清晰、字段也都填全了,可以直接 approve 等开 PR 推进。**

辛苦了。这条 issue 我从头读完,有 3 处想具体致谢一下,
也说一下后续推进的建议。

## 具体识别(3 处做得真到位)

### 1. 抓到了一个研究用户的真实痛点
─────────────────────────────────────────
   完整 draft:cat ~/.issue-review-drafts/issue-review-220-comment.md
   一键发布:bash scripts/publish-issue-review.sh 220

📊 5 维度评估
   A. clarity:✅ 标题白话 + body 有具体场景描述
   B. 完整度:✅ 7/7 字段全填 + grill 存档完整
   C. 唯一性:✅ 跟 #155 是子集关系,不是重复
   D. 可执行性:✅ 4 条验收标准都可检
   E. 项目方向:✅ 跟 file-preview Phase 4 plan 对齐
```

### 生成的 Draft

````markdown
---
target_issue: 220
suggested_action: approve
labels_to_add: []
labels_to_remove: []
close: false
generated_at: 2026-05-24T20:45:00Z
---

✅ **这条 PRD 方向清晰、字段也都填全了,可以直接 approve 等开 PR 推进。**

辛苦了。这条 issue 我从头读完,有 3 处想具体致谢一下,也说一下后续推进的建议。

## 具体识别(3 处做得真到位)

### 1. 抓到了一个研究用户的真实痛点

你这条 issue 抓到的不是"功能不全"这种工程视角痛点,
而是研究用户的真实体感 —— 在 100+ cell 的 notebook 里被调试 cell 干扰阅读主线。
这种需求在普通工程视角下容易被压在心底("毕竟可以滚动跳过"),但你显式提出来 +
给出"过滤 hidden + draft tag"的具体方向,**后续 Phase 4 启动 ipynb 渲染时
直接有方案可落地,不需要再 grill 一轮**。

<!-- audit: dim=insight, severity=green, kind=positive -->

### 2. 边界 case 想得很清楚

你在 grill 存档里明确说了"如果整个 notebook 没有任何被过滤的 cell 那就不显示提示行"
—— 这种"没东西的时候不要刷存在感"的细节,是研究用户实际体感的关键。
作为 reviewer 我特别欣赏这种**主动 catch 边界 case 的习惯**,
减少了后续实施时的 grill 往返。

<!-- audit: dim=B-completeness, severity=green, kind=positive -->

### 3. 备选方案诚实交代了 trade-off

"折叠收起所有 cell" 和 "按 cell type 过滤" 你都考虑过且写下了为什么不采用 ——
这种**把思考过程留痕,而不是只留结论**的习惯,
让后续读这条 PRD 的人(包括 3 个月后的你自己)不会反复重新发明轮子。

位置:这条 issue 的"备选方案和取舍"字段。

<!-- audit: dim=A-clarity, severity=green, kind=positive -->

## 下一步建议

按 Phase 4 plan 节奏,这条 PRD 可以等 Phase 3 完成后启动实施。
建议:实施 PR 在 description 里 cite 本 issue,验收 4 条做成 checkbox 跑 CI。

随时开 PR,我会优先 review。
````

---

## 场景 2:Review 一个 placeholder issue(应该升级)

假设 #220 是 1 周前 `/issue-capture` 出的 placeholder,5/7 字段 🚧。

### 终端报告

```
═══ Issue Review Report ═══

📌 #220 [PRD] ipynb 渲染应该考虑 cell tag 过滤
   作者:jianyulin / 状态:open / placeholder=true / 创建:7 天前

💬 一句话判断
   占位 issue 方向清晰但 5/7 字段 🚧,该走升级流程而不是直接 approve。

🎯 建议你做的事:🔧 建议升级(跑 /issue-create #220)
   理由:placeholder + 字段缺 / 5 维度只有 A clarity 过 / B 完整度严重缺
   labels_to_add:[]
   labels_to_remove:[]
   close:false

📝 准备替你发的评论(开头预览):
─────────────────────────────────────────
🔧 **这是个 placeholder,字段大部分还是 🚧,建议先升级再 triage**

辛苦你 1 周前 capture 了这个想法 —— 方向很对("过滤 cell tag" 是研究用户真痛点),
现在该让它升级成完整 PRD,字段填全 + grill 一遍...
─────────────────────────────────────────
   完整 draft:cat ~/.issue-review-drafts/issue-review-220-comment.md
   一键发布:bash scripts/publish-issue-review.sh 220

📊 5 维度评估
   A. clarity:✅ 一句话方向描述清楚
   B. 完整度:🟡 5/7 字段 🚧(prd 模板)
   C. 唯一性:✅ 不跟现有 issue 重复
   D. 可执行性:🟡 无验收标准 / 无范围 / 无备选
   E. 项目方向:✅ 符合 file-preview matrix 方向
```

### 生成的 Draft

````markdown
---
target_issue: 220
suggested_action: restructure
labels_to_add: []
labels_to_remove: []
close: false
generated_at: 2026-05-24T20:45:00Z
---

🔧 **这是个 placeholder,字段大部分还是 🚧,建议先升级再 triage**

辛苦你 1 周前 capture 了这个想法 —— 方向很对("过滤 cell tag" 是研究用户真痛点),
现在该让它升级成完整 PRD,字段填全 + grill 一遍。

## 我观察到的

这条 issue 整体方向我同意:**ipynb 预览过滤调试 cell 是研究用户的真实需求**。
但目前的内容形态还是占位级的:

- 7 个 prd 字段里 5 个还是 🚧 待 grill 补完
- 没说具体过滤哪种 tag(`hidden`?自定义 tag?)
- 没说研究用户怎么知道有 cell 被隐藏(完全静默 vs 可见提示)
- 没有备选方案的 trade-off 留痕
- 没有验收标准

这些字段缺,后续如果直接开 PR 实现,容易**实施跟意图错位**(eg 你想要"只过滤 hidden tag",但实施者理解成"按 cell type 过滤")。

<!-- audit: dim=B-completeness, severity=yellow -->

## 下一步建议

跑 `/issue-create #220` 升级这条占位 —— skill 会拉本 issue 的现有内容作为 grill 起点,
问你 4-5 题(prd 模板分级),把缺的字段填完,然后更新 issue body + 自动移除 placeholder label。

升级完后我会重新 review。

—— 顺便,你 1 周前能 capture 这个想法值得肯定,
这种"好像可以但好像也无所谓"的需求容易被压在心底,
显式记下来才能不丢失。
````

---

## 场景 3:Review 一个建议关闭的 issue(重复)

假设 #221 跟 #208 主题完全一样(都是 docx 渲染相关 bug),应该 close。

### 终端报告

```
═══ Issue Review Report ═══

📌 #221 [BUG] docx 预览偶尔崩
   作者:某协作者 / 状态:open / placeholder=false / 创建:1 天前

💬 一句话判断
   跟 1 个月前 #208 完全重复,#208 还在 open + 有更详细的 bundle,建议关闭本条转 #208。

🎯 建议你做的事:❌ 建议关闭(指向 #208)
   理由:#208 内容更完整 / 同一个崩溃模式 / 单一权威原则
   close:true

📝 准备替你发的评论(开头预览):
─────────────────────────────────────────
❌ **这条跟 #208 是同一件事,我建议关闭本条,讨论统一到 #208**

辛苦你 catch 了这个 bug —— 但我看下来,1 个月前的 #208 已经在跟踪同一个崩溃模式,
而且 #208 已经有完整 bundle 和 5 个用户的复现报告...
─────────────────────────────────────────
   完整 draft:cat ~/.issue-review-drafts/issue-review-221-comment.md
   一键发布:bash scripts/publish-issue-review.sh 221

📊 5 维度评估
   A. clarity:✅ bug 描述清楚
   B. 完整度:🟡 缺 bundle
   C. 唯一性:🔴 跟 #208 完全重复
   D. 可执行性:🟡 重现路径简单
   E. 项目方向:✅ —
```

### 生成的 Draft

````markdown
---
target_issue: 221
suggested_action: close
labels_to_add: ["duplicate"]
labels_to_remove: []
close: true
generated_at: 2026-05-24T20:45:00Z
---

❌ **这条跟 #208 是同一件事,我建议关闭本条,讨论统一到 #208**

辛苦你 catch 了这个 bug —— 但我看下来,1 个月前的 #208 已经在跟踪同一个崩溃模式,
而且 #208 已经有完整 bundle 和 5 个用户的复现报告。

## 我的判断依据

你描述的"docx 预览偶尔崩" 跟 #208 "docx 预览在某些文件下 crash" 是同一个根因 ——
都指向 mammoth 库在特定 docx 子集(老版本 .doc / 加密文档)处理时抛异常,
渲染器外壳没兜住。

按"单一权威"原则,同一件事应该只在一个地方追踪。**#208 内容更完整,
本条该关闭,把讨论集中过去**。

<!-- audit: dim=C-uniqueness, severity=red, ref=issue-208 -->

## 下一步建议

我准备在关闭本条的同时:
- 加 `duplicate` label,标明指向 #208
- 在 #208 评论里补一条 "@<本 issue 作者> 提了相同问题"(你的报告也算证据,#208 修复后会通知你)

如果你觉得本条有 #208 没 cover 的细节(eg 你的特定 .doc 文件类型 / 特定 macOS 版本),
请在 #208 下面评论补充。

—— 谢谢你的报告,bug 协作就是这样越多眼睛越好。
````

---

## 终端工作流耗时估算

对 #220 跑完整 review 流程大概:

```
$ /issue-review #220
[skill 拉 context + 5 维度评估 ~30 秒]

[user 看 4 component 终端报告 ~30 秒]

$ cat ~/.issue-review-drafts/issue-review-220-comment.md
[user 审 draft ~1 分钟]

$ bash scripts/publish-issue-review.sh 220
[评论 + close + label 一键完成 ~5 秒]

总耗时:~2-3 分钟
```

对比"user 自己人工 review 同样质量"的时间:**15-25 分钟**(读完 issue + 看 PRD / plan 验证方向 + 写致谢 + 想下一步)。

**5-8 倍效率提升**,而且不漏 surface(因为 5 维度全过 + audit 尾巴留痕)。

---

## 学到什么(回看时记得)

1. **5 维度评估默认严苛** —— 大多数 issue 至少有一两个 🟡,不要为了让 issue 通过而把 🟡 降成 ✅
2. **致谢必须 3 要素结构**(抓到了什么 / 为什么不容易 / 连锁好处),不写空话
3. **placeholder issue 该升级而不是 approve** —— 走 🔧 动作,指向 `/issue-create #N`
4. **重复 issue 该关闭并指向原 issue** —— 走 ❌ 动作 + duplicate label + close
5. **audit 尾巴的 `dim=` 字段** —— 不用 A/B/C/D/E 编号,用语义化关键词(insight / completeness / uniqueness / clarity 等)
6. **E 维度(项目方向一致)是 Sedna 价值最高的检查** —— 一个跟方向冲突的 issue approve 进来,修复成本远大于 review 时多读 PRD / plan
