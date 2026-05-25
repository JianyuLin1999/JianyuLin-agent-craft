# 2026-05-25 — 审查严苛度入仓 + skill 文档从 Sedna 迁到本仓库

## What

两件事一起做:

**1. 新建共享单源 [`knowledge-assets/review-rigor.md`](../../knowledge-assets/review-rigor.md)** — 跨 reviewer skill 共享的"审查严苛度"双层架构。跟 [`comment-voice.md`](../../knowledge-assets/comment-voice.md) 配套:一个管"找出多少",一个管"怎么说出来"。

**2. 顺手把之前放在 Sedna repo 的两个 skill 文档迁过来**:
- `Sedna/docs/collaboration/comment-voice.md` → `knowledge-assets/comment-voice.md`
- `Sedna/docs/changelog/2026-05-24-comment-voice-discipline-skill-dna.md` → `docs/changelog/`

Sedna repo 同步:删两个迁出文件 + 留 1 条指针 changelog 避免 grep 断链。

## Why 合并一条 changelog

这两件事在叙事上是**同一根线**:

- 2026-05-22 跑 #213 issue review 5 轮 draft 迭代 → 抽出措辞纪律 → 入 Sedna repo(2026-05-24)
- 2026-05-25 复盘最近几次 PR review 太松 → 抽出审查严苛度纪律 → 触发"该入哪个仓库"的问题
- 答案是**独立的 skill 知识仓库**(本仓库),既不该污染 Sedna 也不该只留本地
- 所以 2026-05-25 这天同时:① 新建 review-rigor + changelog ② 把 comment-voice 顺势迁过来 ③ Sedna repo cleanup

合并一条 changelog 让叙事完整,不切碎。

## Why 审查严苛度独立成文 + 共享单源

**症状**:reviewer 跑 PR review 时,语义判断"看上去都过" → 直接 0 nit 放行。最近几次连续放行后才意识到漏了一批本该 surface 的 nit。

**根因**:不是 reviewer persona 不够挑剔,是**审查层和措辞层混在一个心理模型里**。`comment-voice.md` 立的"指控 vs 委婉是对立失败模式"被误用作"对代码也要妥协" → 审查阈值漂移。

**解法**:双层物理分离。Layer A 审查层挑剔不封顶,Layer B 措辞层温和说话。`review-rigor.md` 锁 Layer A 的 4 个机制(至少 3 个 surface 基线 / 维度扫描 / 严重度三级 / 0 nit 反思),`comment-voice.md` 锁 Layer B。

**全部抽象内容在共享文件**,本 changelog 不重复。

## Why 迁出 Sedna repo

`comment-voice.md` 入 Sedna repo `docs/collaboration/` 严格说是越界:

- Sedna 是**生物医学研究 agent 系统**,不是"个人 skill / 协作纪律集合"
- 评论语言纪律是**跨项目共享**的(任何 reviewer 都该用,不只 Sedna),放 Sedna 仓库等于把通用知识绑到产品仓库
- 未来如果 reviewer 在别的项目用同样纪律,从 Sedna repo 拉文件很奇怪

**独立仓库才是单一权威**。本仓库专管 skill / workflow / 跨项目知识资产。

## 沉淀路径

```
具体协作摩擦 ──┐
              ├──→ 抽象原则文件(knowledge-assets/*.md) ──→ 本 changelog 记录"发生了这件事"
观察期失败 ───┘     (n 次都能用,跨项目可寻址)               (历史追溯,不放原则)
```

抽象层在 `knowledge-assets/`,演化在那里发生。本 changelog 是历史指针。

## 哲学锚

- **A2 泛化优先** — 一次具体审查太松 → 抽出可复用"双层架构" → 永久消除"挑剔 vs 温和"伪选择
- **A22 编译优于链接** — 共享文件单源,不让多个 skill 各自维护漂移版本
- **0.2 活文档** — 原则在共享文件演化,本 changelog 保持轻量(只指针不重抄)
- **A14 信任梯度** — 抽象原则 > 具体事件经验
- **单一职责仓库** — Sedna 管产品代码,本仓库管 skill 知识资产,各自单一权威

## 后续可做

- 本机 skill `~/.claude/skills/pr-review/` + `~/.claude/skills/issue-review/` 同步进本仓库 `skills/` 目录(2026-05-25 一并做)
- 本机 `~/.claude/skills/SHARED-COMMENT-VOICE.md` 改 symlink 指向 `<agent-craft-path>/knowledge-assets/comment-voice.md`
- 跑下一次 PR review 实战检验 7 维度扫描 + 0 nit 反思是否真把阈值漂移挡住

## 关联

- 共享原则:[`knowledge-assets/review-rigor.md`](../../knowledge-assets/review-rigor.md)(审查层)+ [`knowledge-assets/comment-voice.md`](../../knowledge-assets/comment-voice.md)(措辞层)
- 上一条相关:[2026-05-24 评论语言纪律首次入仓](2026-05-24-comment-voice-discipline-skill-dna.md)
- 引用方:本仓库 [`skills/pr-review/`](../../skills/pr-review/) + [`skills/issue-review/`](../../skills/issue-review/)
