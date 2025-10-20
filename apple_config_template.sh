#!/bin/bash

# =============================================================================
# Apple Developer配置模板
# 请填入您的实际信息
# =============================================================================

# Apple Developer配置
export TEAM_ID="YOUR_TEAM_ID"                    # 替换为您的Team ID
export APPLE_ID="your@email.com"                 # 替换为您的Apple ID
export APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"  # 替换为您的App专用密码

# 项目配置
export PROJECT_NAME="马夫"
export SCHEME_NAME="Life"
export BUNDLE_IDENTIFIER="com.xj.life"
export BUILD_CONFIGURATION="Release"

# 构建路径配置
export PROJECT_PATH="/Users/tangxiaojun/Downloads/Life"
export ARCHIVE_PATH="${PROJECT_PATH}/build/马夫.xcarchive"
export EXPORT_PATH="${PROJECT_PATH}/build/Export"
export LOG_FILE="${PROJECT_PATH}/build_log.txt"

# 版本配置 (留空则自动递增)
export VERSION_NUMBER=""
export BUILD_NUMBER=""

# 其他配置
export VERBOSE=false
export BUILD_ONLY=false

echo "✅ Apple Developer配置已加载"
echo "📱 项目: $PROJECT_NAME"
echo "🏢 Team ID: $TEAM_ID"
echo "📧 Apple ID: $APPLE_ID"
echo "🔑 App专用密码: ${APP_SPECIFIC_PASSWORD:0:4}-****-****-****"
