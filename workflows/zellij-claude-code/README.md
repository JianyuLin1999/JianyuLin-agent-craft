# Zellij + Claude Code 终端工作台

这是一套给 **Claude Code 日常使用**准备的 Zellij 配置。

可以把它想成一张专门给 AI 助手工作的书桌:Claude Code 坐在桌前处理任务,Zellij 负责把桌面分成几个区域。平时这张桌子不抢键盘,你敲什么都直接送进 Claude Code;只有你按下特定的 `Alt` / `Ctrl` 组合键时,桌子才帮你切换区域、开新区域、查看历史输出或管理会话。

## 这里有什么

| 文件 | 作用 |
|---|---|
| `config.kdl` | Zellij 的主配置。核心是快捷键、默认模式、复制方式和插件别名。 |
| `setup.sh` | 一键安装/部署脚本。新电脑上运行它,会检查 Zellij 是否已安装,备份旧配置,再把 `config.kdl` 放到 `~/.config/zellij/config.kdl`。 |

## 这套配置解决什么问题

默认的 Zellij 像一张按钮很多的桌子:功能很全,但某些快捷键可能会和 Claude Code、shell、编辑器抢输入。对 AI 编程来说,最烦的不是少一个功能,而是你以为自己在给 Claude Code 发指令,结果外层工具把按键截走了。

这份配置的取舍是:

- **平时安静**:默认进入 `locked` 模式,大多数按键都直接交给终端里的 Claude Code。
- **需要时快**:`Alt+h/j/k/l` 或 `Alt+方向键` 可以直接切窗格,不用先进入 Zellij 的完整操作模式。
- **做完回到安静状态**:很多窗格、标签、滚动、会话操作完成后会自动回到 `locked` 模式,减少“我现在到底在哪个模式”的心智负担。
- **防误退出**:移除了容易误触的 `Ctrl+q` 退出路径。想安全离开会话,用 `Ctrl+g` 进入 normal 模式,再 `Ctrl+o` 进入会话管理,最后按 `d` detach。

代价也很明确:

- 它不是一份“保留 Zellij 默认习惯”的配置,因为 `clear-defaults=true` 会清掉默认快捷键,只留下这里重新定义的按键。
- 它偏 macOS,因为复制命令写的是 `copy_command "pbcopy"`。Linux 用户需要改成 `xclip -selection clipboard` 或 `wl-copy`。
- 所有 `Alt` 快捷键都依赖终端把 Option/Alt 当作 Meta 键发送。如果终端没开这个设置,这张“书桌”的很多按钮会像没接上线一样按不动。

## 快捷键速查

### 日常模式:默认 locked

| 快捷键 | 做什么 |
|---|---|
| `Alt+h/j/k/l` | 左/下/上/右切换窗格。 |
| `Alt+方向键` | 同样用于切换窗格。 |
| `Alt+n` | 新建窗格。 |
| `Alt+z` | 当前窗格全屏/还原。 |
| `Alt+f` | 切换浮动窗格。 |
| `Alt++` / `Alt+-` | 放大/缩小窗格。 |
| `Alt+i` / `Alt+o` | 当前标签向左/向右移动。 |
| `Ctrl+g` | 进入 normal 模式,打开 Zellij 的完整操作入口。 |

### 解锁后:normal 模式入口

| 快捷键 | 进入哪里 |
|---|---|
| `Ctrl+p` | 窗格管理:新建、左右/上下拆分、关闭、全屏等。 |
| `Ctrl+t` | 标签管理:新建、切换、重命名、关闭等。 |
| `Ctrl+s` | 滚动模式:看历史输出、搜索、翻页。 |
| `Ctrl+n` | 调整大小。 |
| `Ctrl+o` | 会话管理:会话列表、detach 等。 |
| `Ctrl+g` | 回到 locked 模式。 |

## 安装方式

在这个目录运行:

```bash
./setup.sh
```

脚本会做三件事:

1. 如果系统里还没有 Zellij,它会尝试安装。macOS 上走 Homebrew,Linux 上优先走 Cargo。
2. 如果你已经有 `~/.config/zellij/config.kdl`,它会先备份成带时间戳的 `.bak` 文件。
3. 把这里的 `config.kdl` 复制到 `~/.config/zellij/config.kdl`。

手动安装也可以:

```bash
mkdir -p ~/.config/zellij
cp config.kdl ~/.config/zellij/config.kdl
```

然后运行:

```bash
zellij
```

## macOS 的 Option 键设置

如果 `Alt+h`、`Alt+n` 这些键没有反应,通常不是 Zellij 坏了,而是终端没有把 Option 键当作 Meta 键发出去。也就是说,你按了桌面上的按钮,但按钮线没有接到 Zellij。

常见终端设置:

| 终端 | 设置 |
|---|---|
| iTerm2 | `Preferences > Profiles > Keys > General > Left Option key > Esc+` |
| Alacritty | `window.option_as_alt = "Both"` |
| Kitty | `macos_option_as_alt yes` |
| WezTerm | 默认通常可用。 |

## 维护提醒

如果后面要继续改这套工作台,优先先问一个问题:这个按键会不会抢走 Claude Code 或 shell 本来要用的输入?

如果会,就把它放到 normal 模式里,让用户先按 `Ctrl+g` 解锁再操作。如果不会,才适合放在默认 locked 模式下当快捷按钮。
