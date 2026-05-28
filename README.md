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

#### GitHub 协作家族(共享 SHARED-READABILITY + SHARED-COMMENT-VOICE)

| 名称 | 说明 |
|---|---|
| [`pr-review`](skills/pr-review/SKILL.md) | 替 user 审 GitHub PR — 3 件事(理解 / 评估 / 反馈),全部 inline 在终端,user 说"发"用 gh tool 直接发到 GitHub |
| [`issue-review`](skills/issue-review/SKILL.md) | 替 user 审 GitHub Issue — 3 件事(理解 / 评估 / 反馈)+ 5 维度 + 7 盲区扫描 + 5 种建议动作 |
| [`issue-create`](skills/issue-create/SKILL.md) | 替 user 把"脑暴一句话"变成完整 issue — 主动调研 codebase 拿事实证据 + grill 带证据问 + 填模板。也支持 `/issue-create #N` 升级占位 |
| [`issue-capture`](skills/issue-capture/SKILL.md) | 地铁手机场景极低摩擦记录脑暴占位 issue,跳 grill,等后续 `/issue-create #N` 升级填完 |

#### 语言风格 / 通用工具

| 名称 | 说明 |
|---|---|
| [`talk-clear`](skills/talk-clear/SKILL.md) | 把任何面向人类阅读的输出写成"完全不懂代码的人也能读懂" — 教授口吻 + 比喻贯穿全文 + 落具体场景。默认全局启用,也支持显式调用 |
| [`notebooklm-professor-clarity`](skills/notebooklm-professor-clarity/SKILL.md) | 让 NotebookLM 输出"简单易懂但不失深度"的通俗报告体讲解 |
| [`caveman-cn`](skills/caveman-cn/SKILL.md) | 中文版 caveman 极简清晰模式:压缩废话,但保留技术准确性、必要语境和行动判断 |
| [`grill-with-docs`](skills/grill-with-docs/SKILL.md) | Matt Pocock 的文档感知 grilling skill:用领域词汇表和 ADR 约束方案讨论 |

### Knowledge Assets(跨 skill 共享的抽象原则)

| 名称 | 说明 |
|---|---|
| [`readability.md`](knowledge-assets/readability.md) | 输出语言风格的唯一真相源 — 教授口吻 / 比喻建立世界并贯穿全文 / 落具体场景 / 警惕行政性段落自动豁免。**`talk-clear` 和 GitHub 协作 4 skill 都 inline 引用这一份**(改一处,5 处同步) |
| [`comment-voice.md`](knowledge-assets/comment-voice.md) | 写 PR / issue 评论的措辞纪律:三条核心原则 + 两个对立失败模式 + 8 条 deterministic 自检 |
| [`review-rigor.md`](knowledge-assets/review-rigor.md) | 审查严苛度双层架构:Layer A(对代码挑剔不封顶)+ Layer B(对作者温和说话)物理分离 |
| [`caveman-cn-design.md`](knowledge-assets/caveman-cn-design.md) | `caveman-cn` 的中文语境设计理念:保留高信号压缩哲学,不把文化适配解释放进 skill 本体 |

## 使用方式

新增条目时,优先使用 `templates/` 下的模板,并参考 [`docs/conventions.md`](docs/conventions.md) 中的命名和版本规则。

skill 的演化历史在 [`docs/changelog/`](docs/changelog/) 下,按 `YYYY-MM-DD-主题.md` 格式存放。
