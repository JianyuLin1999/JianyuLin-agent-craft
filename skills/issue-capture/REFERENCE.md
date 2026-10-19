# issue-capture 详细规则

本文件随 issue-capture 分发，不依赖其他 issue skill。

## 占位原则

只记录用户明确说过的信息和快速检索得到的相关文件路径。多想法自动拆分，不追问、不深入调研、不做重复检测；没有信息的字段标为 `🚧 待 grill 补完`。正文用用户第一人称，Background 单独说明检索结果。

## 模板路由(判断 bug / prd / gap)

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

## 文字格式

通用可读性规则(白话 / 路径独立成"位置:"行 / 编号禁入正文)在 SKILL.md 的 SHARED-READABILITY 段里。本节只讲 issue 特有的。

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

**绝不**写 "暂无" / "TBD" / "N/A" — 这些词太低调,后期整理占位 issue 时会被漏掉。🚧 这个 emoji 是物理标记,扫一眼就看到哪些字段还没整理完。

### 5.3 user 第一人称具体长什么样

| ✅ | ❌ |
|---|---|
| "我看到 ipynb 平铺所有 cell..." | "user 描述他看到 ipynb 平铺..." |
| "我建议默认隐藏 hidden tag" | "user 在 grill 中提到隐藏 hidden tag" |
| "目前我不清楚做法,可能..." | "user 暂未提出做法" |

每段都用第一人称视角写,**你把自己当成 user 在写**。

唯一例外:Background 字段(见开头的占位原则) — 那段是你调研产出的,用第三人称描述检索结果。

---

## 草稿文件的结构 + frontmatter

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
placeholder: true
generated_by: issue-capture
generated_at: 2026-05-21T01:30:00Z
---

# [PRD] ipynb 预览应该支持按 cell tag 过滤

## Background — 我调研到的现有代码

> (本字段由 skill 第三人称写,跟 user 主观字段视觉分开)

- `notebook-renderer.tsx`：关键词命中的相关文件，具体实现待后续调研
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

🚧 待 grill 补完

...

## 什么算完成

- [ ] ...
- [ ] ...
```

**几条关键约束**:
- frontmatter 是 YAML,`publish-issue.sh` 靠它解析 title / labels / placeholder
- body 是 markdown,直接对应 Sedna template 的字段
- frontmatter 跟 body 之间用 `---` 分隔(标准 markdown frontmatter 格式)

## 发布与后续完善

从目标仓库目录调用本 skill 的 `scripts/publish-issue.sh`。发布前确认模板所需标签及 `placeholder` 标签已存在；发布脚本只创建 issue，不创建标签。可用 `--dry-run <slug>` 预览，`--all` 批量发布。

`fetch-issue-context.sh` 是可选的完整上下文工具，capture 不需要为重复检测调用它。

用户之后要求完善占位 issue 时，读取原 issue，补充调研并用 `easy-grill-zh` 澄清缺失信息。经用户授权后用 `gh issue edit` 更新原 issue，信息补齐后移除 `placeholder` 标签；不要调用创建脚本再开一条。
