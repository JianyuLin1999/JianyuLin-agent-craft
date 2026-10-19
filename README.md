# agent-craft

这里存的是我**调教 AI 助手**(Claude 这类)做事的"工作说明书"。每份说明书让 AI 在某类活上(比如审代码改动、建待办事项、把术语翻译成人话)按固定标准产出。沉淀好之后,以后任何项目直接拿来用。

核心原则:

- **可复用**:每个条目都应该能被直接复制、改写或接入工具。
- **可读性优先**:结构清楚,命名直白,不为了"完整"制造负担。
- **版本化管理**:重要提示词和工作流都通过 Git 留下修改历史。
- **跨项目共享**:抽象层(知识资产 / skill 本体)不绑特定产品代码仓库,任何项目都能引用。
- **知识产权意识**:这是个人知识资产库。除非后续明确添加开源许可证,默认保留所有权利。

## 目录结构

```text
.
├── skills/             # 可复用提示词、能力卡、agent skill
├── workflows/          # 可重复执行的流程、SOP、操作规范
├── knowledge-assets/   # 方法论、框架、术语表、长期知识资产
├── templates/          # 新增 skill / workflow 时使用的模板
└── docs/               # 仓库维护规则、命名约定、changelog
```

## 已收录

### Skills

**Skill 是什么** — 给 AI 助手(像 Claude)装的一份"工作说明书"。你喊一声某个名字(比如 `/pr-review`),她就按那份说明书干活,产出固定风格的结果。下面每条说明书都是干一类具体的活。

本仓库维护以下 8 个 skill：

| 名称 | 用途 |
|---|---|
| [`easy-grill-zh`](skills/easy-grill-zh/SKILL.md) | 用中文白话逐步追问计划，把需要技术背景的问题转成能凭直觉回答的问题。 |
| [`remove-ai-tone`](skills/remove-ai-tone/SKILL.md) | 让文字清楚、自然，保留理解和执行所需的信息。另有[详细说明](docs/remove-ai-tone-guide.html)。 |
| [`pr-review`](skills/pr-review/SKILL.md) | 审查 GitHub PR，解释改动、问题和处理建议。 |
| [`issue-capture`](skills/issue-capture/SKILL.md) | 快速把想法记成占位 issue；所需规则和脚本随 skill 一起提供。 |
| [`write-a-prd`](skills/write-a-prd/SKILL.md) | 通过访谈、代码调研和模块设计形成产品需求文档，并提交为 GitHub issue。 |
| [`prd-to-plan`](skills/prd-to-plan/SKILL.md) | 将 PRD 拆成可独立验证的端到端实施阶段，保存到本地 `plans/`。 |
| [`tdd`](skills/tdd/SKILL.md) | 按红—绿—重构循环开发，每次围绕一个可观察行为编写测试并实现。 |
| [`improve-codebase-architecture`](skills/improve-codebase-architecture/SKILL.md) | 查找架构改进机会，对比模块接口设计，形成重构提案。 |

复制 skill 时请复制整个目录，包含配套参考文档和脚本。

### Knowledge Assets — 几个 skill 共用的"规则手册"

这些不是 skill 本身,而是 skill 引用的**共享规则手册**。把它们单独抽出来,是为了"改一处,所有用到的 skill 同时刷新" — 像剧团的演员手册,不管哪个演员演,都按这份手册说台词。

| 名称 | 它是啥 |
|---|---|
| [`readability.md`](knowledge-assets/readability.md) | GitHub 协作家族仍在使用的共享语言检查材料。通用写作入口已经迁移到 `remove-ai-tone`;后续共享材料的更新以新 Skill 的读者判断和场景调整为准。 |
| [`comment-voice.md`](knowledge-assets/comment-voice.md) | **写 GitHub 评论怎么说话不冒犯作者的规则手册** — 心里挑剔无上限,嘴上对人温和(说事实 / 带"我" / 给作者两条路选,不下指令)。 |
| [`review-rigor.md`](knowledge-assets/review-rigor.md) | **审别人工作时的双层纪律** — 心里挑剔得严苛,嘴上温和不指控。讲这两件事为什么能同时存在(物理分离)。 |
| [`caveman-cn-design.md`](knowledge-assets/caveman-cn-design.md) | `caveman-cn` 极简模式的设计理念 — 为什么这样设计、怎么平衡"短"和"不失准"。 |

## 使用方式

新增条目时,优先使用 `templates/` 下的模板,并参考 [`docs/conventions.md`](docs/conventions.md) 中的命名和版本规则。

skill 的演化历史在 [`docs/changelog/`](docs/changelog/) 下,按 `YYYY-MM-DD-主题.md` 格式存放。
