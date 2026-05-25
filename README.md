# agent-craft

这个仓库用于集中管理个人的 skill、提示词、工作流和知识资产 —— 跟 AI agent(Claude / Codex 等)协作时沉淀的可复用资产。

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

| 名称 | 说明 |
|---|---|
| [`pr-review`](skills/pr-review/SKILL.md) | 深度审 GitHub PR + 产 3 类 draft(评论 / issue / 文档 patch)一键发布。DNA / 涟漪 / 工程债 + 7 维盲点扫描 + 严重度三级 + 双层审查纪律 |
| [`issue-review`](skills/issue-review/SKILL.md) | 深度评 GitHub issue 的 5 维度 + 7 维盲点扫描,产建议动作 + 致谢评论 draft |
| [`notebooklm-professor-clarity`](skills/notebooklm-professor-clarity/SKILL.md) | 让 NotebookLM 输出"简单易懂但不失深度"的通俗报告体讲解 |
| [`chinese-concise-clarity`](skills/chinese-concise-clarity/SKILL.md) | 中文极简清晰模式:压缩废话,但保留技术准确性、必要语境和行动判断 |

### Knowledge Assets(跨 skill 共享的抽象原则)

| 名称 | 说明 |
|---|---|
| [`review-rigor.md`](knowledge-assets/review-rigor.md) | 审查严苛度双层架构:Layer A(对代码挑剔不封顶)+ Layer B(对作者温和说话)物理分离 |
| [`comment-voice.md`](knowledge-assets/comment-voice.md) | 写 PR / issue 评论的措辞纪律:三条核心原则 + 两个对立失败模式 + 8 条 deterministic 自检 |

## 使用方式

新增条目时,优先使用 `templates/` 下的模板,并参考 [`docs/conventions.md`](docs/conventions.md) 中的命名和版本规则。

skill 的演化历史在 [`docs/changelog/`](docs/changelog/) 下,按 `YYYY-MM-DD-主题.md` 格式存放。
