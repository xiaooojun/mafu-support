#!/bin/bash

# =============================================================================
# 快速运行应用脚本
# 简化版本，快速启动应用
# =============================================================================

echo "🚀 快速启动应用..."

# 检查Xcode是否运行
if pgrep -x "Xcode" > /dev/null; then
    echo "📱 在Xcode中运行应用..."
    
    # 使用xcodebuild在Xcode中运行
    xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "generic/platform=iOS" build
    
    if [ $? -eq 0 ]; then
        echo "✅ 构建成功！"
        echo "📱 请在Xcode中按 Cmd+R 运行应用"
    else
        echo "❌ 构建失败"
    fi
else
    echo "📱 启动Xcode并运行应用..."
    
    # 打开Xcode项目
    open Life.xcodeproj
    
    # 等待Xcode启动
    sleep 3
    
    # 构建项目
    xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "generic/platform=iOS" build
    
    if [ $? -eq 0 ]; then
        echo "✅ 构建成功！"
        echo "📱 Xcode已打开，请按 Cmd+R 运行应用"
    else
        echo "❌ 构建失败"
    fi
fi

echo "🎉 准备完成！"
