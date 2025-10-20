#!/bin/bash

# =============================================================================
# iOS应用一键打包上传脚本 (简化版)
# 项目: 马夫 (生活记录应用)
# 使用方法: ./quick_build.sh
# =============================================================================

set -e

# 项目配置
PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
PROJECT_NAME="Life"
SCHEME_NAME="Life"
WORKSPACE_PATH="${PROJECT_PATH}/Life.xcodeproj"

# Apple Developer配置 - 请修改为您的信息
TEAM_ID="YOUR_TEAM_ID"           # 替换为您的Team ID
APPLE_ID="your@email.com"        # 替换为您的Apple ID
APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"  # 替换为您的App专用密码

# 构建配置
BUILD_CONFIGURATION="Release"
ARCHIVE_PATH="${PROJECT_PATH}/build/Life.xcarchive"
EXPORT_PATH="${PROJECT_PATH}/build/Export"

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

# 检查配置
check_config() {
    log_info "检查配置..."
    
    if [ "$TEAM_ID" = "YOUR_TEAM_ID" ] || [ "$APPLE_ID" = "your@email.com" ] || [ "$APP_SPECIFIC_PASSWORD" = "xxxx-xxxx-xxxx-xxxx" ]; then
        log_error "请先修改脚本中的Apple Developer配置信息:"
        log_error "  - TEAM_ID: 您的Team ID"
        log_error "  - APPLE_ID: 您的Apple ID"
        log_error "  - APP_SPECIFIC_PASSWORD: 您的App专用密码"
        exit 1
    fi
    
    log_success "配置检查通过"
}

# 清理并创建构建目录
prepare_build() {
    log_info "准备构建环境..."
    
    # 清理旧的构建文件
    if [ -d "${PROJECT_PATH}/build" ]; then
        rm -rf "${PROJECT_PATH}/build"
    fi
    
    mkdir -p "${PROJECT_PATH}/build"
    log_success "构建环境准备完成"
}

# 构建Archive
build_archive() {
    log_info "开始构建Archive..."
    
    xcodebuild archive \
        -project "$WORKSPACE_PATH" \
        -scheme "$SCHEME_NAME" \
        -configuration "$BUILD_CONFIGURATION" \
        -archivePath "$ARCHIVE_PATH" \
        -destination "generic/platform=iOS" \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        | tee "${PROJECT_PATH}/build_log.txt"
    
    if [ ! -d "$ARCHIVE_PATH" ]; then
        log_error "Archive构建失败"
        exit 1
    fi
    
    log_success "Archive构建成功"
}

# 导出IPA
export_ipa() {
    log_info "导出IPA文件..."
    
    # 创建ExportOptions.plist
    cat > "${PROJECT_PATH}/ExportOptions.plist" << EOF
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
    
    # 导出IPA
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "${PROJECT_PATH}/ExportOptions.plist" \
        | tee -a "${PROJECT_PATH}/build_log.txt"
    
    # 查找生成的IPA文件
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
    
    xcrun altool --upload-app \
        -f "$IPA_FILE" \
        -u "$APPLE_ID" \
        -p "$APP_SPECIFIC_PASSWORD" \
        --verbose \
        | tee -a "${PROJECT_PATH}/build_log.txt"
    
    log_success "应用已成功上传到TestFlight"
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    
    if [ -f "${PROJECT_PATH}/ExportOptions.plist" ]; then
        rm -f "${PROJECT_PATH}/ExportOptions.plist"
    fi
    
    log_success "清理完成"
}

# 主函数
main() {
    echo "=========================================="
    echo "🚀 iOS应用一键打包上传脚本"
    echo "项目: 马夫"
    echo "=========================================="
    
    START_TIME=$(date)
    log_info "开始时间: $START_TIME"
    
    # 执行构建流程
    check_config
    prepare_build
    build_archive
    export_ipa
    upload_to_testflight
    cleanup
    
    # 完成
    END_TIME=$(date)
    echo ""
    log_success "🎉 构建上传完成!"
    log_info "开始时间: $START_TIME"
    log_info "结束时间: $END_TIME"
    
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)
    log_info "📱 IPA文件: $IPA_FILE"
    log_info "📋 构建日志: ${PROJECT_PATH}/build_log.txt"
    log_success "🚀 请到App Store Connect查看上传结果"
}

# 捕获中断信号
trap 'log_error "构建过程被中断"; cleanup; exit 1' INT TERM

# 执行主函数
main "$@"
