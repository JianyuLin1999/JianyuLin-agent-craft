# Skill Workflows Knowledge Base

这个仓库用于集中管理个人的 skill、提示词、工作流和知识资产。

核心原则：

- **可复用**：每个条目都应该能被直接复制、改写或接入工具。
- **可读性优先**：结构清楚，命名直白，不为了“完整”制造负担。
- **版本化管理**：重要提示词和工作流都通过 Git 留下修改历史。
- **知识产权意识**：这是个人知识资产库。除非后续明确添加开源许可证，默认保留所有权利。

## 目录结构

```text
.
├── skills/             # 可复用提示词、能力卡、agent skill
├── workflows/          # 可重复执行的流程、SOP、操作规范
├── knowledge-assets/   # 方法论、框架、术语表、长期知识资产
├── templates/          # 新增 skill / workflow 时使用的模板
└── docs/               # 仓库维护规则和命名约定
```

## 已收录

| 类型 | 名称 | 说明 |
|---|---|---|
| Skill | [`notebooklm-professor-clarity`](skills/notebooklm-professor-clarity/SKILL.md) | 让 NotebookLM 输出“简单易懂但不失深度”的通俗报告体讲解 |

## 使用方式

新增条目时，优先使用 `templates/` 下的模板，并参考 [`docs/conventions.md`](docs/conventions.md) 中的命名和版本规则。

