#!/bin/bash

# =============================================================================
# iOS应用构建配置脚本
# 用于设置Apple Developer信息和项目配置
# =============================================================================

# 项目配置
PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
CONFIG_FILE="${PROJECT_PATH}/build_config.sh"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 创建配置文件
create_config() {
    log_info "创建构建配置文件..."
    
    cat > "$CONFIG_FILE" << 'EOF'
#!/bin/bash
# iOS应用构建配置文件
# 请根据您的实际情况修改以下配置

# Apple Developer配置
export TEAM_ID="YOUR_TEAM_ID"                    # 替换为您的Team ID
export APPLE_ID="your@email.com"                 # 替换为您的Apple ID
export APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"  # 替换为您的App专用密码

# 项目配置
export PROJECT_NAME="Life"
export SCHEME_NAME="Life"
export BUNDLE_IDENTIFIER="com.xj.life"
export BUILD_CONFIGURATION="Release"

# 构建路径配置
export PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
export ARCHIVE_PATH="${PROJECT_PATH}/build/Life.xcarchive"
export EXPORT_PATH="${PROJECT_PATH}/build/Export"
export LOG_FILE="${PROJECT_PATH}/build_log.txt"

# 版本配置 (留空则自动递增)
export VERSION_NUMBER=""
export BUILD_NUMBER=""

# 其他配置
export VERBOSE=false
export BUILD_ONLY=false
EOF
    
    log_success "配置文件已创建: $CONFIG_FILE"
    log_warning "请编辑配置文件并填入您的Apple Developer信息"
}

# 验证配置
validate_config() {
    log_info "验证配置..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        log_info "请先运行: $0 --create-config"
        exit 1
    fi
    
    # 加载配置
    source "$CONFIG_FILE"
    
    # 检查必要配置
    if [ "$TEAM_ID" = "YOUR_TEAM_ID" ] || [ "$APPLE_ID" = "your@email.com" ] || [ "$APP_SPECIFIC_PASSWORD" = "xxxx-xxxx-xxxx-xxxx" ]; then
        log_error "请先配置Apple Developer信息"
        log_info "编辑配置文件: $CONFIG_FILE"
        exit 1
    fi
    
    log_success "配置验证通过"
}

# 显示配置信息
show_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log_info "当前配置:"
        echo "----------------------------------------"
        cat "$CONFIG_FILE" | grep -E "^export" | sed 's/export //' | sed 's/="[^"]*"/=***/' | sed 's/=""/=未设置/'
        echo "----------------------------------------"
    else
        log_warning "配置文件不存在"
    fi
}

# 显示帮助
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --create-config          创建配置文件"
    echo "  --validate-config       验证配置"
    echo "  --show-config           显示当前配置"
    echo "  -h, --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --create-config       # 创建配置文件"
    echo "  $0 --validate-config     # 验证配置"
    echo "  $0 --show-config         # 显示配置"
    echo ""
}

# 主函数
main() {
    case "${1:-}" in
        --create-config)
            create_config
            ;;
        --validate-config)
            validate_config
            ;;
        --show-config)
            show_config
            ;;
        -h|--help)
            show_help
            ;;
        "")
            log_info "iOS应用构建配置工具"
            echo ""
            show_help
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
