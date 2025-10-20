#!/bin/bash

# =============================================================================
# iOS应用自动化打包并上传到TestFlight脚本
# 项目: 马夫 (生活记录应用)
# 作者: AI Assistant
# 创建时间: $(date)
# =============================================================================

set -e  # 遇到错误立即退出

# =============================================================================
# 配置参数 - 请根据实际情况修改
# =============================================================================

# 项目配置
PROJECT_NAME="Life"
PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
SCHEME_NAME="Life"
WORKSPACE_PATH="${PROJECT_PATH}/Life.xcodeproj"
BUNDLE_IDENTIFIER="com.xj.life"
WIDGET_BUNDLE_IDENTIFIER="com.xj.life.Widget"

# 构建配置
BUILD_CONFIGURATION="Release"
ARCHIVE_PATH="${PROJECT_PATH}/build/Life.xcarchive"
EXPORT_PATH="${PROJECT_PATH}/build/Export"
EXPORT_OPTIONS_PLIST="${PROJECT_PATH}/ExportOptions.plist"

# Apple Developer配置
TEAM_ID="Q37XP946YJ"  # 请填入您的Team ID
APPLE_ID="blessy0907@icloud.com"  # 请填入您的Apple ID
APP_SPECIFIC_PASSWORD="amjo-jjgg-nibk-eyii"  # 请填入您的App专用密码

# 版本配置
VERSION_NUMBER=""  # 留空则自动递增
BUILD_NUMBER=""    # 留空则自动递增

# 日志配置
LOG_FILE="${PROJECT_PATH}/build_log.txt"
VERBOSE=false

# =============================================================================
# 颜色输出函数
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# =============================================================================
# 工具函数
# =============================================================================

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "命令 '$1' 未找到，请先安装"
        exit 1
    fi
}

# 检查必要工具
check_prerequisites() {
    log_info "检查必要工具..."
    
    check_command "xcodebuild"
    check_command "xcrun"
    
    # 检查Xcode版本
    XCODE_VERSION=$(xcodebuild -version | head -n1)
    log_info "使用 $XCODE_VERSION"
    
    # 检查是否登录Apple ID
    if ! xcrun altool --list-providers -u "$APPLE_ID" -p "$APP_SPECIFIC_PASSWORD" &> /dev/null; then
        log_error "Apple ID 认证失败，请检查APPLE_ID和APP_SPECIFIC_PASSWORD"
        exit 1
    fi
    
    log_success "必要工具检查完成"
}

# 清理构建目录
clean_build_directory() {
    log_info "清理构建目录..."
    
    if [ -d "${PROJECT_PATH}/build" ]; then
        rm -rf "${PROJECT_PATH}/build"
        log_info "已清理旧的构建文件"
    fi
    
    mkdir -p "${PROJECT_PATH}/build"
    log_success "构建目录准备完成"
}

# 自动递增版本号
increment_version() {
    log_info "处理版本号..."
    
    # 获取当前版本号
    CURRENT_VERSION=$(xcodebuild -project "$WORKSPACE_PATH" -showBuildSettings | grep MARKETING_VERSION | head -1 | awk '{print $3}')
    CURRENT_BUILD=$(xcodebuild -project "$WORKSPACE_PATH" -showBuildSettings | grep CURRENT_PROJECT_VERSION | head -1 | awk '{print $3}')
    
    # 设置版本号
    if [ -z "$VERSION_NUMBER" ]; then
        VERSION_NUMBER="$CURRENT_VERSION"
    fi
    
    # 设置构建号
    if [ -z "$BUILD_NUMBER" ]; then
        # 自动递增构建号
        BUILD_NUMBER=$((CURRENT_BUILD + 1))
    fi
    
    log_info "版本号: $VERSION_NUMBER"
    log_info "构建号: $BUILD_NUMBER"
    
    # 更新项目版本号
    xcodebuild -project "$WORKSPACE_PATH" -target "$PROJECT_NAME" -configuration "$BUILD_CONFIGURATION" MARKETING_VERSION="$VERSION_NUMBER" CURRENT_PROJECT_VERSION="$BUILD_NUMBER"
    xcodebuild -project "$WORKSPACE_PATH" -target "WidgetExtension" -configuration "$BUILD_CONFIGURATION" MARKETING_VERSION="$VERSION_NUMBER" CURRENT_PROJECT_VERSION="$BUILD_NUMBER"
    
    log_success "版本号更新完成"
}

# 创建ExportOptions.plist
create_export_options() {
    log_info "创建导出选项配置..."
    
    cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF
    
    log_success "导出选项配置创建完成"
}

# 构建项目
build_project() {
    log_info "开始构建项目..."
    
    # 构建Archive
    log_info "创建Archive..."
    xcodebuild archive \
        -project "$WORKSPACE_PATH" \
        -scheme "$SCHEME_NAME" \
        -configuration "$BUILD_CONFIGURATION" \
        -archivePath "$ARCHIVE_PATH" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        MARKETING_VERSION="$VERSION_NUMBER" \
        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        | tee -a "$LOG_FILE"
    
    if [ ! -d "$ARCHIVE_PATH" ]; then
        log_error "Archive创建失败"
        exit 1
    fi
    
    log_success "Archive创建成功: $ARCHIVE_PATH"
}

# 导出IPA
export_ipa() {
    log_info "导出IPA文件..."
    
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
        | tee -a "$LOG_FILE"
    
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
    
    if [ ! -f "$IPA_FILE" ]; then
        log_error "IPA导出失败"
        exit 1
    fi
    
    log_success "IPA导出成功: $IPA_FILE"
}

# 上传到TestFlight
upload_to_testflight() {
    log_info "上传到TestFlight..."
    
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
    
    # 使用xcrun altool上传
    xcrun altool --upload-app \
        -f "$IPA_FILE" \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD" \
        --verbose \
        | tee -a "$LOG_FILE"
    
    log_success "应用已成功上传到TestFlight"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    
    # 保留Archive和IPA文件，只清理其他临时文件
    if [ -f "$EXPORT_OPTIONS_PLIST" ]; then
        rm -f "$EXPORT_OPTIONS_PLIST"
    fi
    
    log_success "清理完成"
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -v, --version VERSION   指定版本号"
    echo "  -b, --build BUILD       指定构建号"
    echo "  -t, --team TEAM_ID      指定Team ID"
    echo "  -a, --apple-id ID       指定Apple ID"
    echo "  -p, --password PASS     指定App专用密码"
    echo "  --verbose               详细输出"
    echo "  --clean-only            仅清理构建目录"
    echo "  --build-only            仅构建，不上传"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认配置"
    echo "  $0 -v 1.2.0 -b 10                    # 指定版本号和构建号"
    echo "  $0 --build-only                      # 仅构建，不上传"
    echo ""
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                VERSION_NUMBER="$2"
                shift 2
                ;;
            -b|--build)
                BUILD_NUMBER="$2"
                shift 2
                ;;
            -t|--team)
                TEAM_ID="$2"
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
            --verbose)
                VERBOSE=true
                shift
                ;;
            --clean-only)
                clean_build_directory
                log_success "仅清理模式完成"
                exit 0
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查必要参数
    if [ -z "$TEAM_ID" ] || [ -z "$APPLE_ID" ] || [ -z "$APP_SPECIFIC_PASSWORD" ]; then
        log_error "请提供必要的Apple Developer信息:"
        log_error "  - Team ID"
        log_error "  - Apple ID"
        log_error "  - App专用密码"
        log_error ""
        log_error "您可以通过以下方式提供:"
        log_error "  1. 修改脚本中的配置参数"
        log_error "  2. 使用命令行参数: $0 -t TEAM_ID -a APPLE_ID -p PASSWORD"
        exit 1
    fi
    
    # 开始构建流程
    log_info "开始iOS应用自动化构建流程..."
    log_info "项目: $PROJECT_NAME"
    log_info "Bundle ID: $BUNDLE_IDENTIFIER"
    log_info "配置: $BUILD_CONFIGURATION"
    
    # 记录开始时间
    START_TIME=$(date)
    log_info "开始时间: $START_TIME"
    
    # 执行构建步骤
    check_prerequisites
    clean_build_directory
    increment_version
    create_export_options
    build_project
    export_ipa
    
    # 如果指定了仅构建模式，则不上传
    if [ "$BUILD_ONLY" = true ]; then
        log_success "构建完成，跳过上传步骤"
    else
        upload_to_testflight
    fi
    
    cleanup
    
    # 记录结束时间
    END_TIME=$(date)
    log_success "构建流程完成!"
    log_info "开始时间: $START_TIME"
    log_info "结束时间: $END_TIME"
    
    # 显示结果
    echo ""
    log_success "🎉 构建成功完成!"
    log_info "📱 应用版本: $VERSION_NUMBER ($BUILD_NUMBER)"
    log_info "📦 Archive位置: $ARCHIVE_PATH"
    if [ -f "$IPA_FILE" ]; then
        log_info "📱 IPA位置: $IPA_FILE"
    fi
    log_info "📋 详细日志: $LOG_FILE"
    
    if [ "$BUILD_ONLY" != true ]; then
        log_success "🚀 应用已上传到TestFlight，请到App Store Connect查看"
    fi
}

# 捕获中断信号
trap 'log_error "构建过程被中断"; cleanup; exit 1' INT TERM

# 执行主函数
main "$@"
