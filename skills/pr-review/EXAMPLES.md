# pr-review EXAMPLES

应用到真实场景的完整 sample。让你回看 skill 时能"看见" draft 长什么样。

---

## 场景:对 PR #192(file-preview Phase 1)跑 `/pr-review #192`

PR #192 真实情况:**21 文件 / +1529 / -122**,把 `FileBrowser.tsx` 硬编码 if-else 重构为渲染器注册表。Phase 0 baseline snap 9/9 一致,Contract Test 46 个,工程债嗅探出 2 件小事。

---

## 终端报告(新 format,包含 4 个 component:一句话判断 / 建议动作 / 评论预览 / surface 统计)

```
═══ PR Review Report ═══

📌 PR #192 / 作者 Yennfe
   feat(file-preview): Phase 1 注册表骨架 + Contract Test + 5 渲染器迁移

💬 一句话判断
   核心改造完成度很高,21 文件 +1529/-122,Phase 0 锁定的 9 个回归测试
   逐字节全过,零行为变化承诺兑现,可以直接合 + 立刻启动 Phase 2 docx。

🎯 建议你做的事:✅ 直接 merge + 留致谢评论 + Phase 2 启动信号
   理由:核心改造完整 / 契约测试覆盖到位 / 回归测试 0 破 / 0 阻塞事项

📝 准备替你发的 PR 评论(开头预览):
─────────────────────────────────────────
✨ **Phase 1 这版比 Phase 0 又高一档,可以直接合 + 启动 Phase 2**

辛苦了,从头读完。这条 PR 的核心改造完成度很高,具体识别和顺带观察如下。

## 具体识别(3 处做得真漂亮)

### 1. 把"该不该拉文件内容"这个决策搬到每个渲染器自己声明
─────────────────────────────────────────
   完整 draft:cat ~/.pr-review-drafts/pr-192-comment.md
   一键发布:bash scripts/publish.sh #192

📊 surface 统计
   🔴 阻塞:0   🟡 应改:1   🟢 观察:3(含 2 个正向)

📂 已生成 draft:
   - pr-192-comment.md                  (PR 评论:致谢 + 1 🟡 + 3 🟢 + Phase 2 启动信号)
   - pr-192-issue-phase-1-followup.md   (Phase 1 follow-up 3 件小事:Windows CI / 流式测试 / 文件大小接入)
```

**为什么这套 format**:user 在终端 30 秒看完就能决定"是直接 publish 还是先 cat 完整 draft 微调"。一句话判断 + 建议动作 + 评论预览 = 核心决策信息全部在终端,不需要 cat draft 才知道 skill 准备说什么。

---

## Draft 1:`~/.pr-review-drafts/pr-192-comment.md`

```markdown
✨ **Phase 1 这版比 Phase 0 又高一档,可以直接合 + 启动 Phase 2**

辛苦了,从头读完。这条 PR 的核心改造完成度很高,具体识别和顺带观察如下。

## 具体识别(3 处做得真漂亮)

### 1. 把"该不该拉文件内容"这个决策搬到每个渲染器自己声明

旧 FileBrowser 主组件里硬编码一个"二进制扩展名清单",每加一种格式都得改主组件。
现在每个渲染器自己声明"我需不需要预取文件内容",主组件查这个声明决定。
**从此加新格式不用改主组件**。这是产品哲学里"加格式 = 一个新文件 + 一行注册"的真正落地。

### 2. 契约测试真做到了"注册即覆盖"

新写的契约测试用参数化展开,把"任何渲染器都该过的契约"7 项自动跑在所有已注册渲染器上。
Phase 2 你写 docx 渲染器那一刻,这 7 项契约**自动跑在 docx 上,你不用手动加测试**。

架构约束在 CI 红绿里,不在文档里 —— 真正可执行。

### 3. 渲染器外壳的折中,代码注释里诚实交代

原本设计是外壳组件自动净化所有渲染输出,折中改成外壳给个工具函数让渲染器自己调。
作者在外壳代码文件顶部把"为什么折中 + 后续阶段怎么兜底"完整写下来。

**把代码跟设计的偏离主动写下来,比假装按设计做了好得多。**

## 顺带提几件事

🟡 **代码里有个"占位的 0",未来某阶段启动前必须改成真值**

文件浏览器决定"用哪个渲染器"时,会问"这个文件多大"。当前阶段暂时写死 0
(因为现有 5 个渲染器都不看文件大小)。但后续要加的"大 JSON 渲染器"明确按大小分派 ——
小文件走纯文本,大文件走树状渲染。如果不改成真值,**大 JSON 渲染器永远不会被选中**。

位置:文件浏览器主组件里调用渲染器选择的地方。

—— 留占位时应该贴 TODO 注释,提示后续阶段必须改。

<!-- audit: file=FileBrowser.tsx, ripple=A-backward, dna=A14, severity=yellow -->

🟢 **HTML 净化的设计从"外壳自动包"改成"渲染器自己记得调"**

原本设计:所有渲染器输出 HTML 时,外壳组件自动跑一遍净化(过滤危险标签)。
现在改成:外壳提供一个净化工具,每个渲染器自己记得调用。
作者在代码顶部诚实交代了这个偏离,并承诺后续用恶意脚本测试兜底验证。

位置:渲染器外壳代码文件顶部注释。

—— 把代码跟设计的偏离主动写下来是好习惯。

<!-- audit: file=host.tsx, ripple=D-doc, dna=0.2, severity=green, kind=concern -->

🟢 **HTML 预览的沙箱权限规则已经写进自动测试**(正向)

HTML 文件预览在受限沙箱里加载,只允许最小权限(不跑脚本 / 不提交表单 / 不跳转)。
现在自动测试明确检查这一点,以后谁不小心放开权限,测试立刻红。

位置:渲染器契约测试文件里。

—— 把安全规则写进自动测试是好实践。

<!-- audit: file=renderer-contract.test.tsx, ripple=B-forward, dna=A22, severity=green, kind=positive -->

🟢 **Phase 0 baseline 9 个 snap 逐字节一致**(正向)

Phase 1 全部重构后,Phase 0 锁定的 9 个回归测试逐字节通过,**新架构产出的 HTML 跟旧架构完全相同**。
零行为变化承诺兑现。

位置:baseline 测试文件 + snap 文件。

—— 重构时保留 baseline + 零行为变化是好实践。

<!-- audit: file=baseline.test.tsx, ripple=A-backward, dna=A22, severity=green, kind=positive -->

## Phase 2 启动信号 🚀

截图里那个 `标书.docx` 显示乱码 —— 现在物质条件全部就位:

- 注册表骨架 ✓
- 渲染器外壳兜异常 ✓
- HTML 净化工具(给 docx 解析后输出的 HTML 用)✓
- 契约测试自动覆盖新渲染器 ✓
- 打包配置已经把 docx 解析库单独拆开 ✓

按 Plan §Phase 2 节奏:估 2-3 天,新写 `renderers/docx.tsx`(mammoth.js dynamic import),
配 3 类失败 fixture(损坏 / 加密 / 超大),目标是"在 Sedna 打开 标书.docx 显示正常文档"。

随时开 PR,我会优先 review。
```

**说明**:这份 draft 的 PR comment 就是给作者(Yennfe)看的。GitHub 会自动隐藏 `<!-- audit: ... -->` 注释,作者看不到哲学编号,只看到白话内容。reviewer(建宇)审 draft 时能看到 audit 尾巴,做 audit / 后续增量。

---

## Draft 2:`~/.pr-review-drafts/pr-192-issue-phase-1-followup.md`

```markdown
# file-preview Phase 1 follow-up:Windows CI / /api/raw 流式测试 / fileSize 接入真值

## 起源

Phase 1 PR #192 已 merge(commit `15e7541`)。Plan §"验收标准" 里 3 件小事推迟到独立 PR 处理,这个 issue 跟踪。

**都不阻塞 Phase 2 启动**,但第 3 件在 Phase 4 启动前必须做完。

---

## 1. Windows CI runner

### 触发场景

Windows 用户的 Sedna 实例打开各种格式文件时,**路径分隔符 / 文件名编码 / 换行符** 等差异在 macOS-only CI 上发现不了。

### 为什么 Phase 1 没做

PR body 明示:"`apt-get` / `chmod` / `sudo` 等 Linux 特定步骤改写成跨平台,改动面大于本 PR 范围"。

### 做法

GitHub Actions matrix 加 `windows-latest`,把 Linux-specific 步骤包成跨平台。

---

## 2. /api/raw 100MB 不爆内存的回归测试

### 触发场景

用户打开 87MB 的 xlsx 或 50MB 的 ipynb 时,后端不能一次性把整个文件加载到内存。

### 当前状态

代码本身已是流式实现,但**没有回归测试**保护这件事。

### 做法

写一个测试:运行时生成 100MB temp file → curl /api/raw → 断言内存 peak < 50MB。

---

## 3. FileBrowser 里的 fileSize: 0 接入真值

### 触发场景

Phase 4 的 json-tree 渲染器按 fileSize 分派(<100KB → text, ≥100KB → json-tree)。**Phase 4 启动前不修这一行,json-tree 永远不会被命中**。

### 三种做法

- A. file list API 携带每个文件的 size(改动大)
- B. fetch HEAD 拿 Content-Length(轻)
- C. 新增 /api/file-meta 端点(中)

按 Plan 依赖关系,**最迟在 Phase 4 PR 启动前完成**。建议 Phase 3 实施时顺手做。

---

## 优先级

P2 —— 都不阻塞 Phase 2 启动,但 #3 在 Phase 4 启动前必须完成。

## 关联

- Phase 1 PR #192
- 父 issue #155 文件预览格式支持矩阵

<!-- audit: source=pr-192-review, kind=followup-issue -->
```

---

## Draft 3(不存在):假设 Phase 0 baseline 不全过

如果 #192 提交时 baseline snap 有破,会生成第 3 份 draft:

```markdown
🔴 **Phase 0 baseline 锁定的 9 个回归测试中有 N 个破了**

新架构产出的 HTML 跟旧架构不再逐字节一致。Phase 1 的核心承诺(零行为变化)未兑现。

位置:baseline 测试文件输出的 snap 文件。

具体破的:
- CSV 渲染:旧 `<table class="preview-table">` → 新 `<table class="data-table">`
- 纯文本:旧 `<pre class="file-browser-preview-content">` → 新 `<pre class="text-preview">`

**作者需要决定**:
- 是无意改了(回退到原 className)
- 还是有意改(明确说明,更新 baseline + 在 PR description 列出"明示行为变化")

—— Phase 0 是回归保护的第一道防线,破了就不能 ship。

<!-- audit: file=baseline.test.tsx.snap, ripple=A-backward, dna=A22, severity=red -->
```

**注意 🔴 严重度**:Phase 0 baseline 破 = 阻塞 ship,不可商量。

---

## 终端报告对应的 PR 实际场景

如果当时跑过这个 skill,**reviewer(建宇)实际工作流大约是这样**:

```
$ /pr-review #192
[skill 跑 30 秒]
[终端出报告,提示 cat draft]

$ cat ~/.pr-review-drafts/pr-192-comment.md
[建宇花 2 分钟读 draft]
[判断:draft 写得 OK,直接发]

$ bash scripts/publish.sh #192
[Published: PR comment, Issue: Phase 1 follow-up]
[整个 review 流程 5 分钟搞完]
```

对比"建宇自己人工 review 同样质量"的时间:30-40 分钟(读 21 文件 diff + 翻 plan + 写 thank-you + 想 follow-up issue 内容 + 写 issue body)。

**6-8 倍效率提升,而且不漏 surface**(因为 skill 跑 5 方向涟漪 + 工程债 + DNA 全套)。

---

## 学到什么(回看时记得)

1. **draft 第一稿一定会违反白话原则** —— LLM 默认会堆术语,**自检不可跳**
2. **正向 observation 也用 🟢 surface** —— 不只是"坏事 surface,好事不说"
3. **audit 尾巴在 GitHub 渲染时自动隐藏**,作者只看到白话
4. **Phase 启动信号要具体到"物质条件就位清单"**,不是空话
5. **PR 评论用 user 口吻直接对作者说,身份必须自洽** —— 不能出现"建宇你判断" / "skill 嗅探到"等泄露身份的话(详见 SKILL.md §1.2)
6. **Merge 必须致谢,空话致谢比不致谢更伤** —— 致谢走 §5.1 ⭐ 3 要素结构(做了什么 / 为什么不容易 / 连锁好处),不要用形容词堆砌
7. **DNA 编号 / 章节号(A14 / 0.2 / §X.X)只能藏在 audit 尾巴**,正文用白话原则名 + 场景代替
