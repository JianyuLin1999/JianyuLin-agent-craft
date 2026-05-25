# 2026-05-24 — 评论语言纪律沉淀进 skill DNA

> 注:本文件原 2026-05-24 入 Sedna repo `docs/collaboration/`,2026-05-25 整体迁到本仓库(详见 [2026-05-25 review 严苛度 + 文档迁出 Sedna](2026-05-25-review-rigor-and-docs-relocation.md))。原文保留,仅修正失效链接。

## What

新建共享单源 [`knowledge-assets/comment-voice.md`](../../knowledge-assets/comment-voice.md),约束 reviewer 写 PR / issue 评论时的措辞。

本机评论类 skill(`~/.claude/skills/pr-review/` / `~/.claude/skills/issue-review/`)引用本文件作为 source of truth。本机 `~/.claude/skills/SHARED-COMMENT-VOICE.md` 是镜像(手动同步或 symlink)。

**全部内容在那个文件里**,本 changelog 不重复,避免双源漂移。

## Why 独立成文 + 共享单源

- 评论语言纪律跟"评估方法"(5 维度 / DNA / 涟漪)正交 —— 评估再准,语言用不对就触发作者防御
- 多个评论类 skill 共享同一份规则,避免半年后各自维护漂移版本
- 内容**完全抽象**(无事件 / 无 issue 编号 / 无协作者名字),agent 读它时不会被具体场景分散注意力
- 放仓库内(而不是只在本机 `~/.claude/skills/`),保证跨机器跨协作者一致性

## 沉淀路径

```
具体协作摩擦  →  抽象原则文件(knowledge-assets/comment-voice.md)  →  本 changelog 记录"发生了这件事"
   (1 次)         (n 次都能用,仓库内可寻址)                              (历史追溯,不放原则)
```

本 changelog 故意不展开原则内容 —— 原则的归属在共享文件,改进 / 演化都在那里发生。changelog 只是历史指针。

## 哲学锚

- **A2 泛化优先** — 一次具体协作不顺 → 抽出可复用原则 → 永久消除一类问题
- **A22 编译优于链接** — 共享文件单源,不让多个 skill 各自维护漂移版本
- **0.2 活文档** — 原则在共享文件演化,本 changelog 保持轻量(只指针不重抄)
- **A14 信任梯度** — 抽象原则 > 具体事件经验。事件用来抽原则,抽完事件就该退出主体

## 后续可做

- 本机镜像改 symlink:`ln -sf <agent-craft-path>/knowledge-assets/comment-voice.md ~/.claude/skills/SHARED-COMMENT-VOICE.md`,根除手动同步漂移风险
- 跑下一次 review 实战检验自检条目是否真 0 容忍可执行

## 关联

- 共享文件:[`knowledge-assets/comment-voice.md`](../../knowledge-assets/comment-voice.md)
- 引用方:本仓库 [`skills/pr-review/`](../../skills/pr-review/) + [`skills/issue-review/`](../../skills/issue-review/),本机 `~/.claude/skills/pr-review/` + `~/.claude/skills/issue-review/`
