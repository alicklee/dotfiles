#!/bin/bash
# install.sh

set -e

# 动态获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SCRIPT_DIR"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

link_config() {
    local config_name="$1"
    local source_path="$DOTFILES/$config_name"
    local target_path="$CONFIG_DIR/$config_name"
    
    info "处理: $config_name"
    info "源路径: $source_path"
    info "目标路径: $target_path"
    
    # 检查源目录是否存在
    if [ ! -d "$source_path" ]; then
        error "源目录不存在: $source_path"
        return 1
    fi
    
    # 如果目标已存在
    if [ -e "$target_path" ]; then
        if [ -L "$target_path" ]; then
            local current_link="$(readlink "$target_path")"
            if [ "$current_link" = "$source_path" ]; then
                info "✓ 软链接已正确设置"
                return 0
            else
                warn "⚠ 存在其他软链接，移除: $current_link"
                rm "$target_path"
            fi
        else
            warn "⚠ 备份已存在的配置"
            mkdir -p "$BACKUP_DIR"
            mv "$target_path" "$BACKUP_DIR/"
        fi
    fi
    
    # 创建目标目录的父目录
    mkdir -p "$(dirname "$target_path")"
    
    # 创建软链接
    ln -sf "$source_path" "$target_path"
    info "✅ 创建软链接成功"
}

main() {
    info "🚀 开始设置 dotfiles 软链接..."
    info "📁 Dotfiles 目录: $DOTFILES"
    info "🎯 配置目录: $CONFIG_DIR"
    info "💾 备份目录: $BACKUP_DIR"
    echo
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    
    # 配置列表
    local configs=("nvim" "kitty")
    
    for config in "${configs[@]}"; do
        link_config "$config"
        echo
    done
    
    # 验证结果
    info "📋 最终结果:"
    echo "═══════════════════════════════════════"
    for config in "${configs[@]}"; do
        local target="$CONFIG_DIR/$config"
        if [ -L "$target" ] && [ -e "$target" ]; then
            echo -e "${GREEN}✅ $config${NC} -> $(readlink "$target")"
        else
            echo -e "${RED}❌ $config: 软链接无效${NC}"
        fi
    done
    echo "═══════════════════════════════════════"
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        warn "原配置已备份到: $BACKUP_DIR"
    fi
    
    info "🎉 安装完成！"
}

main "$@"
