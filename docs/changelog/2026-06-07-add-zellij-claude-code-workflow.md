# 2026-06-07 Add Zellij + Claude Code Workflow

新增 `workflows/zellij-claude-code/`,收录一套给 Claude Code 日常使用的 Zellij 个性化配置。

这次放进来的不是新的 AI skill,而是一套可重复执行的终端环境搭建流程。它像一张给 Claude Code 工作用的书桌:默认尽量安静,不抢键盘输入;需要切窗格、开窗格、看历史输出时,再用 `Alt` / `Ctrl` 快捷键操作外层 Zellij。

包含内容:

- `config.kdl`: Zellij 主配置,默认 `locked` 模式,保留 `Alt+h/j/k/l`、`Alt+n`、`Alt+z` 等高频操作,并移除容易误触的 `Ctrl+q` 退出路径。
- `setup.sh`: 新机器部署脚本,会检查 Zellij、备份旧配置,再把新配置放到 `~/.config/zellij/config.kdl`。
- `README.md`: 用人话解释这套配置为什么适合 Claude Code、怎么安装、macOS Option 键为什么会影响快捷键、以及 Linux 用户需要调整 `pbcopy` 的地方。

适合放在 `workflows/` 而不是 `skills/`:它不是给 AI 助手读的“工作说明书”,而是人可以重复执行的“环境搭建流程”。
