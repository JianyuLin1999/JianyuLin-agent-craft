# Repository Conventions

## Naming

- 文件夹使用小写英文和连字符：`notebooklm-professor-clarity`
- 名称优先表达用途，而不是抽象概念
- 同类资产放在同一顶层目录下

## Skill Format

每个 skill 默认使用：

```text
skills/<skill-name>/SKILL.md
```

`SKILL.md` 建议包含：

- YAML frontmatter：名称、描述、版本、适用工具、状态
- 使用场景：什么时候用这个 skill
- 可复制正文：真正要粘贴到工具里的提示词或工作流
- 维护笔记：只保留必要的版本说明

## Versioning

- 初版使用 `0.1.0`
- 明显改变行为或输出风格时升级 minor version
- 只修正文案、错别字或排版时升级 patch version

## Writing Standard

- 保留高价值规则，避免穷举式清单
- 每个条目都要能被直接使用
- 复杂内容优先通过例子、场景和类比降低理解成本

