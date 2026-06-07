#!/bin/bash
# Zellij + Claude Code 配置一键安装脚本
# 在新电脑上运行: bash setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZELLIJ_DIR="$HOME/.config/zellij"

# 1. 安装 Zellij (如果未安装)
if ! command -v zellij &> /dev/null; then
    echo "[1/3] 安装 Zellij..."
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v brew &> /dev/null; then
            brew install zellij
        else
            echo "  请先安装 Homebrew: https://brew.sh"
            exit 1
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        if command -v cargo &> /dev/null; then
            cargo install zellij
        else
            echo "  请通过包管理器安装 zellij，或先安装 Rust: https://rustup.rs"
            exit 1
        fi
    fi
else
    echo "[1/3] Zellij 已安装: $(zellij --version)"
fi

# 2. 部署配置
echo "[2/3] 部署 Zellij 配置..."
mkdir -p "$ZELLIJ_DIR"
if [[ -f "$ZELLIJ_DIR/config.kdl" ]]; then
    cp "$ZELLIJ_DIR/config.kdl" "$ZELLIJ_DIR/config.kdl.bak.$(date +%Y%m%d%H%M%S)"
    echo "  已备份原配置"
fi
cp "$SCRIPT_DIR/config.kdl" "$ZELLIJ_DIR/config.kdl"
echo "  配置已部署到 $ZELLIJ_DIR/config.kdl"

# 3. 终端 Option 键提醒 (macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    echo "[3/3] macOS 终端配置提醒:"
    echo ""
    echo "  所有 Alt 快捷键需要终端将 Option 键作为 Meta 发送:"
    echo "  - iTerm2:  Preferences > Profiles > Keys > General > Left Option key > Esc+"
    echo "  - Alacritty: window.option_as_alt = \"Both\""
    echo "  - Kitty:   macos_option_as_alt yes"
    echo "  - WezTerm: 默认已正确"
    echo ""
fi

echo "Done! 运行 zellij 即可使用。"
echo "配置速查: head -28 $ZELLIJ_DIR/config.kdl"
