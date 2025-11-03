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
progress() { echo -e "${BLUE}⟩${NC} $1" }

# 配置项定义 - 在这里添加新的配置
CONFIG_ITEMS=(
    "file:.zshrc:$HOME/.zshrc"
    "dir:nvim:$CONFIG_DIR/nvim"
    "dir:kitty:$CONFIG_DIR/kitty"
    "file:starship.toml:$CONFIG_DIR/starship.toml"
    "dir:tmux:$CONFIG_DIR/tmux"
    "file:.tmux.conf:$HOME/.tmux.conf"
)

# 通用链接函数
link_item() {
    local type="$1"
    local name="$2"
    local source_path="$DOTFILES/$name"
    local target_path="$3"
    
    progress "处理 $name"
    
    # 检查源文件/目录是否存在
    if [[ "$type" == "dir" && ! -d "$source_path" ]] || [[ "$type" == "file" && ! -f "$source_path" ]]; then
        warn "源${type}不存在: $source_path"
        return 1
    fi
    
    # 如果目标已存在
    if [[ -e "$target_path" ]]; then
        if [[ -L "$target_path" ]]; then
            local current_link="$(readlink "$target_path")"
            if [[ "$current_link" == "$source_path" ]]; then
                success "$name 软链接已正确设置"
                return 0
            else
                warn "存在其他软链接: $current_link"
                rm "$target_path"
            fi
        else
            warn "备份已存在的配置: $name"
            mkdir -p "$BACKUP_DIR"
            mv "$target_path" "$BACKUP_DIR/"
        fi
    fi
    
    # 创建目标目录的父目录
    mkdir -p "$(dirname "$target_path")"
    
    # 创建软链接
    ln -sf "$source_path" "$target_path"
    success "创建 $name 软链接成功"
}

# 处理所有配置项
process_configs() {
    local all_success=true
    
    for item in $CONFIG_ITEMS; do
        # 解析配置项: type:name:target
        local type="${item%%:*}"
        local rest="${item#*:}"
        local name="${rest%%:*}"
        local target="${rest#*:}"
        
        if ! link_item "$type" "$name" "$target"; then
            warn "跳过 $name"
            all_success=false
        fi
        echo
    done
    
    if $all_success; then
        return 0
    else
        return 1
    fi
}

# 验证安装结果
verify_installation() {
    echo -e "${GREEN}📋 最终结果:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    for item in $CONFIG_ITEMS; do
        local type="${item%%:*}"
        local rest="${item#*:}"
        local name="${rest%%:*}"
        local target="${rest#*:}"
        
        if [[ -L "$target" && -e "$target" ]]; then
            echo -e "${GREEN}  ✓ $name${NC} \033[2m→ $(readlink "$target")\033[0m"
        else
            echo -e "${RED}  ✗ $name: 软链接无效${NC}"
        fi
    done
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# 显示备份信息
show_backup_info() {
    if [[ -d "$BACKUP_DIR" && "$(ls -A "$BACKUP_DIR")" ]]; then
        echo
        special "📦 备份文件列表:"
        find "$BACKUP_DIR" -type f | while read file; do
            echo "  📄 $(basename "$file")"
        done
        warn "原配置已备份到: $BACKUP_DIR"
    fi
}

# 显示重新加载提示
show_reload_tips() {
    local reload_needed=false
    local tips=()
    
    for item in $CONFIG_ITEMS; do
        local type="${item%%:*}"
        local rest="${item#*:}"
        local name="${rest%%:*}"
        
        case $name in
            ".zshrc")
                reload_needed=true
                tips+=("运行 'source ~/.zshrc' 或重新打开终端")
                ;;
            ".tmux.conf")
                tips+=("运行 'tmux source-file ~/.tmux.conf'")
                ;;
            "starship.toml")
                tips+=("Starship 配置会在下次启动终端时自动加载")
                ;;
        esac
    done
    
    if $reload_needed || [[ ${#tips} -gt 0 ]]; then
        echo
        info "💡 提示:"
        for tip in $tips; do
            echo "  • $tip"
        done
    fi
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
    
    # 处理所有配置
    process_configs
    
    # 验证结果
    verify_installation
    
    # 显示备份信息
    show_backup_info
    
    # 显示重新加载提示
    show_reload_tips
    
    echo
    success "安装完成！"
}

# 运行主函数
main "$@"
