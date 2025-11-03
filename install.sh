#!/bin/zsh
# install.sh

set -e

# 动态获取脚本所在目录 - zsh 方式
SCRIPT_DIR="${0:a:h}"
DOTFILES="$SCRIPT_DIR"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 美化输出函数
info() { echo -e "${GREEN}➜${NC} $1" }
warn() { echo -e "${YELLOW}➜${NC} $1" }
error() { echo -e "${RED}✗${NC} $1" }
success() { echo -e "${GREEN}✓${NC} $1" }
special() { echo -e "${PURPLE}➜${NC} $1" }

# 进度显示
progress() {
    echo -e "${BLUE}⟩${NC} $1"
}

link_config() {
    local config_name="$1"
    local source_path="$DOTFILES/$config_name"
    local target_path="$CONFIG_DIR/$config_name"
    
    progress "处理 $config_name"
    
    # 检查源目录是否存在
    if [[ ! -d "$source_path" ]]; then
        error "源目录不存在: $source_path"
        return 1
    fi
    
    # 如果目标已存在
    if [[ -e "$target_path" ]]; then
        if [[ -L "$target_path" ]]; then
            local current_link="$(readlink "$target_path")"
            if [[ "$current_link" == "$source_path" ]]; then
                success "$config_name 软链接已正确设置"
                return 0
            else
                warn "存在其他软链接: $current_link"
                rm "$target_path"
            fi
        else
            warn "备份已存在的配置: $config_name"
            mkdir -p "$BACKUP_DIR"
            mv "$target_path" "$BACKUP_DIR/"
        fi
    fi
    
    # 创建目标目录的父目录
    mkdir -p "$(dirname "$target_path")"
    
    # 创建软链接
    ln -sf "$source_path" "$target_path"
    success "创建 $config_name 软链接成功"
}

backup_zshrc() {
    local zshrc_source="$DOTFILES/.zshrc"
    local zshrc_target="$HOME/.zshrc"
    
    progress "检查 .zshrc 文件"
    
    # 检查源文件是否存在
    if [[ ! -f "$zshrc_source" ]]; then
        warn "源 .zshrc 文件不存在: $zshrc_source"
        return 1
    fi
    
    # 如果目标 .zshrc 存在且不是软链接
    if [[ -f "$zshrc_target" && ! -L "$zshrc_target" ]]; then
        warn "备份现有的 .zshrc 文件"
        mkdir -p "$BACKUP_DIR"
        cp "$zshrc_target" "$BACKUP_DIR/.zshrc"
        success "已备份 .zshrc 到 $BACKUP_DIR/.zshrc"
    fi
    
    # 如果目标是软链接，检查是否指向正确位置
    if [[ -L "$zshrc_target" ]]; then
        local current_link="$(readlink "$zshrc_target")"
        if [[ "$current_link" == "$zshrc_source" ]]; then
            success ".zshrc 软链接已正确设置"
            return 0
        else
            warn "存在其他 .zshrc 软链接: $current_link"
            rm "$zshrc_target"
        fi
    fi
    
    # 创建软链接
    ln -sf "$zshrc_source" "$zshrc_target"
    success "创建 .zshrc 软链接成功"
}

link_zshrc() {
    local zshrc_source="$DOTFILES/.zshrc"
    local zshrc_target="$HOME/.zshrc"
    
    progress "处理 .zshrc 文件"
    
    # 检查源文件是否存在
    if [[ ! -f "$zshrc_source" ]]; then
        error "源 .zshrc 文件不存在: $zshrc_source"
        return 1
    fi
    
    # 备份现有的 .zshrc（如果不是软链接）
    if [[ -f "$zshrc_target" && ! -L "$zshrc_target" ]]; then
        special "备份现有的 .zshrc 文件"
        mkdir -p "$BACKUP_DIR"
        cp "$zshrc_target" "$BACKUP_DIR/.zshrc"
        success "已备份 .zshrc 到 $BACKUP_DIR/.zshrc"
    fi
    
    # 如果目标是软链接，检查是否指向正确位置
    if [[ -L "$zshrc_target" ]]; then
        local current_link="$(readlink "$zshrc_target")"
        if [[ "$current_link" == "$zshrc_source" ]]; then
            success ".zshrc 软链接已正确设置"
            return 0
        else
            warn "存在其他 .zshrc 软链接: $current_link"
            rm "$zshrc_target"
        fi
    elif [[ -f "$zshrc_target" ]]; then
        # 如果是普通文件，移除（已经备份过了）
        rm "$zshrc_target"
    fi
    
    # 创建软链接
    ln -sf "$zshrc_source" "$zshrc_target"
    success "创建 .zshrc 软链接成功"
}

main() {
    echo -e "${GREEN}🚀 开始设置 dotfiles 软链接...${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    info "Dotfiles 目录: $DOTFILES"
    info "配置目录: $CONFIG_DIR"
    info "备份目录: $BACKUP_DIR"
    
    if [[ ! -d "$DOTFILES" ]]; then
        error "Dotfiles 目录不存在: $DOTFILES"
        exit 1
    fi
    
    # 创建配置目录
    mkdir -p "$CONFIG_DIR"
    
    # 配置列表
    local configs=(nvim kitty)
    
    # 处理 .zshrc 文件
    link_zshrc
    echo
    
    # 处理其他配置目录
    for config in $configs; do
        link_config "$config"
    done
    
    # 验证结果
    echo
    echo -e "${GREEN}📋 最终结果:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    # 检查 .zshrc
    local zshrc_target="$HOME/.zshrc"
    if [[ -L "$zshrc_target" && -e "$zshrc_target" ]]; then
        echo -e "${PURPLE}  ✓ .zshrc${NC} \033[2m→ $(readlink "$zshrc_target")\033[0m"
    else
        echo -e "${RED}  ✗ .zshrc: 软链接无效${NC}"
    fi
    
    # 检查其他配置
    for config in $configs; do
        local target="$CONFIG_DIR/$config"
        if [[ -L "$target" && -e "$target" ]]; then
            echo -e "${GREEN}  ✓ $config${NC} \033[2m→ $(readlink "$target")\033[0m"
        else
            echo -e "${RED}  ✗ $config: 软链接无效${NC}"
        fi
    done
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    # 显示备份信息
    if [[ -d "$BACKUP_DIR" && "$(ls -A "$BACKUP_DIR")" ]]; then
        echo
        special "📦 备份文件列表:"
        find "$BACKUP_DIR" -type f | while read file; do
            echo "  📄 $(basename "$file")"
        done
        warn "原配置已备份到: $BACKUP_DIR"
    fi
    
    echo
    success "安装完成！"
    
    # 如果创建了新的 .zshrc，提示重新加载
    if [[ -L "$zshrc_target" && -e "$zshrc_target" ]]; then
        echo
        info "💡 提示: 运行 'source ~/.zshrc' 或重新打开终端来应用新的 .zshrc 配置"
    fi
}

# 运行主函数
main "$@"
