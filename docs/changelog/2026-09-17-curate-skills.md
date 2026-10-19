# 精简 skill 目录并导入本机常用 skill

保留 `easy-grill-zh`、`remove-ai-tone`、`pr-review`、`issue-capture`，删除其余 8 个 skill。

从本机 Codex skill 目录原样导入 `write-a-prd`、`prd-to-plan`、`tdd`、`improve-codebase-architecture`，包含全部配套文档。本机 `.agents` 与 `.codex` 的这四份内容一致。

将 `issue-capture` 依赖的发布与上下文脚本移入其自身目录，整理所需参考规则，替换已删除 skill 的调用路径。移除 `easy-grill-zh` 与英文版必须同步的维护要求。更新 README；共享知识资产及历史记录继续保留。
