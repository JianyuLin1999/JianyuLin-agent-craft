# write-for-reader 取代 talk-clear

## 这次增加了什么

- 新增 `write-for-reader`。AI 在写作前自行判断读者、已有知识、沟通目标和载体，再调整术语、解释深度、结构、篇幅、语气、证据和视觉形式。
- 新 Skill 覆盖对话、面向外行的解释、技术调查、学术写作、研究报告、PPT、邮件、工作文档和创意写作。
- 新增详细 HTML 说明。页面解释规则怎样形成、哪些要求跨场景保留、AI 怎样减少提问，并在末尾放入可复制的完整 Skill 和 GitHub 链接。

## talk-clear 怎样处理

- `talk-clear` 退出活跃 Skill 列表，它的 `SKILL.md` 从当前版本移除。
- 原有的背景铺垫、具体例子和局部比方进入 `write-for-reader` 的“面向非专业读者”场景。
- Git 历史继续保留旧文件。用户以后只需要安装和使用 `write-for-reader`。

## 相关更新

- README 使用新 Skill 作为通用写作入口。
- `research-report` 使用新 Skill 的学术写作场景，不再引用 `talk-clear`。
- `skill-craft` 将新 Skill 作为语言风格和例外条款的参考。
