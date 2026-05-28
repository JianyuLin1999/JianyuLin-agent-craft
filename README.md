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

#### GitHub 协作家族 — 帮你审 / 建 / 记 GitHub 上的代码改动和待办

GitHub 是程序员存代码、协作改代码的地方,跟"团队的工作板 + 文件柜"一样。下面 4 个 skill 都跟在这个工作板上做事有关 — 审别人的修改、审待办、新建待办、快速记一笔。

| 名称 | 它替你干啥 |
|---|---|
| [`pr-review`](skills/pr-review/SKILL.md) | 有人给你的代码项目提交了一份**修改建议**(GitHub 上叫 PR),你想知道这个修改靠不靠谱、要不要接受。你喊她,她替你看完一遍,告诉你:这修改在做什么、有没有问题、要不要采纳。你点头她就直接帮你回复作者或合并。**好处**:你不用自己钻代码。 |
| [`issue-review`](skills/issue-review/SKILL.md) | GitHub 上一条"待办想法"(叫 issue,就是别人提的"这个该改一下"的小卡片),你想知道它讲清楚没、能不能开干、要不要让作者再想想。她替你过一遍,写好回复草稿,你点头就发出去 — 关掉 / 加标签这些状态变更也一并做了。 |
| [`issue-create`](skills/issue-create/SKILL.md) | 你脑子里冒出一个想法(比如"那个搜论文的功能应该改一下"),想正经把它记成一条**完整的待办事项**让团队后续来做。她先去翻一遍代码看你这想法跟现有的东西什么关系,再追问你几个关键问题把细节问清楚,最后帮你写好一份规范的待办。 |
| [`issue-capture`](skills/issue-capture/SKILL.md) | 你在**地铁上**(或任何匆忙场景)突然想到"哦这个我之前想改",只有 30 秒,没时间细想。喊她,扔给她一句话,她飞快帮你记成一条**占位草稿**丢到工作板上,贴个"还没想清楚"的标签提醒大家。等你之后有空,跑 `/issue-create #N` 把它填完整。 |

#### 写作 / 通用工具

| 名称 | 它替你干啥 |
|---|---|
| [`talk-clear`](skills/talk-clear/SKILL.md) | 让 AI **任何写给人看的东西**都按"老奶奶能听懂"的标准写 — 举例子、打比方、落到具体场景,不堆术语。默认所有面向人类的输出都自动遵守,不需要你每次喊。例外:跟程序员讨论代码 debug 这种"自己人内部对话"不强制(他们就要术语)。 |
| [`notebooklm-professor-clarity`](skills/notebooklm-professor-clarity/SKILL.md) | 让 **NotebookLM**(Google 出的研究笔记 AI 工具)输出的讲解更通俗易懂,但深度不丢 — 像一个会讲课的教授,而不是干瘪的学术摘要。 |
| [`caveman-cn`](skills/caveman-cn/SKILL.md) | 你跟 AI 聊天觉得她**废话太多**,喊一句"少废话",她立刻切到极简模式 — 只留结论、原因、风险、下一步,不绕弯。 |
| [`grill-with-docs`](skills/grill-with-docs/SKILL.md) | 跟 AI 讨论一个方案的时候,**强制她先翻你项目的术语表和决策档案**,用你项目的语言跟你讨论,不会自己发明词。像新来的咨询师必须先把"内部黑话本子"翻熟了再开会。 |

### Knowledge Assets — 几个 skill 共用的"规则手册"

这些不是 skill 本身,而是 skill 引用的**共享规则手册**。把它们单独抽出来,是为了"改一处,所有用到的 skill 同时刷新" — 像剧团的演员手册,不管哪个演员演,都按这份手册说台词。

| 名称 | 它是啥 |
|---|---|
| [`readability.md`](knowledge-assets/readability.md) | **"AI 怎么说人话"的规则手册** — 教授口吻、举例子、打比方、落到 reader 工作的具体场景。`talk-clear` 和上面 4 个 GitHub 协作 skill 都共用这一份(改一处,5 个 skill 同时刷新)。 |
| [`comment-voice.md`](knowledge-assets/comment-voice.md) | **写 GitHub 评论怎么说话不冒犯作者的规则手册** — 心里挑剔无上限,嘴上对人温和(说事实 / 带"我" / 给作者两条路选,不下指令)。 |
| [`review-rigor.md`](knowledge-assets/review-rigor.md) | **审别人工作时的双层纪律** — 心里挑剔得严苛,嘴上温和不指控。讲这两件事为什么能同时存在(物理分离)。 |
| [`caveman-cn-design.md`](knowledge-assets/caveman-cn-design.md) | `caveman-cn` 极简模式的设计理念 — 为什么这样设计、怎么平衡"短"和"不失准"。 |

## 使用方式

新增条目时,优先使用 `templates/` 下的模板,并参考 [`docs/conventions.md`](docs/conventions.md) 中的命名和版本规则。

skill 的演化历史在 [`docs/changelog/`](docs/changelog/) 下,按 `YYYY-MM-DD-主题.md` 格式存放。
