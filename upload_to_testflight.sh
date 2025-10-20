#!/bin/bash

# =============================================================================
# TestFlight快速上传脚本
# 用于快速上传已构建的IPA到TestFlight
# =============================================================================

set -e

# 配置参数
PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
APPLE_ID=""
APP_SPECIFIC_PASSWORD=""
IPA_PATH=""

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

# 查找最新的IPA文件
find_latest_ipa() {
    local build_dir="${PROJECT_PATH}/build/Export"
    if [ -d "$build_dir" ]; then
        IPA_PATH=$(find "$build_dir" -name "*.ipa" -type f -exec ls -t {} + | head -n1)
        if [ -n "$IPA_PATH" ]; then
            log_info "找到IPA文件: $IPA_PATH"
            return 0
        fi
    fi
    return 1
}

# 上传到TestFlight
upload_to_testflight() {
    log_info "开始上传到TestFlight..."
    
    if [ ! -f "$IPA_PATH" ]; then
        log_error "IPA文件不存在: $IPA_PATH"
        exit 1
    fi
    
    log_info "上传文件: $IPA_PATH"
    
    xcrun altool --upload-app \
        -f "$IPA_PATH" \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD" \
        --verbose
    
    log_success "应用已成功上传到TestFlight"
}

# 显示帮助
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -f, --file IPA_PATH     指定IPA文件路径"
    echo "  -a, --apple-id ID       指定Apple ID"
    echo "  -p, --password PASS     指定App专用密码"
    echo ""
    echo "示例:"
    echo "  $0                                    # 自动查找并上传最新IPA"
    echo "  $0 -f /path/to/app.ipa               # 上传指定IPA文件"
    echo ""
}

# 主函数
main() {
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--file)
                IPA_PATH="$2"
                shift 2
                ;;
            -a|--apple-id)
                APPLE_ID="$2"
                shift 2
                ;;
            -p|--password)
                APP_SPECIFIC_PASSWORD="$2"
                shift 2
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查必要参数
    if [ -z "$APPLE_ID" ] || [ -z "$APP_SPECIFIC_PASSWORD" ]; then
        log_error "请提供Apple ID和App专用密码"
        log_error "使用 -a 和 -p 参数或在脚本中设置"
        exit 1
    fi
    
    # 如果没有指定IPA文件，尝试自动查找
    if [ -z "$IPA_PATH" ]; then
        log_info "自动查找最新的IPA文件..."
        if ! find_latest_ipa; then
            log_error "未找到IPA文件，请使用 -f 参数指定"
            exit 1
        fi
    fi
    
    # 开始上传
    upload_to_testflight
}

main "$@"
