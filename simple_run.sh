#!/bin/bash

# =============================================================================
# 开发完成自动运行脚本 - 简化版
# 使用Xcode直接运行应用
# =============================================================================

echo "🎯 开发完成，自动运行应用..."

# 检查项目状态
if [ ! -f "Life.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 快速构建检查
echo "🔍 快速构建检查..."
xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "generic/platform=iOS" build -quiet

if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    
    # 启动Xcode并运行
    echo "📱 启动Xcode并运行应用..."
    
    # 打开Xcode项目
    open Life.xcodeproj
    
    # 等待Xcode启动
    sleep 2
    
    # 使用osascript在Xcode中运行应用
    echo "🚀 在Xcode中运行应用..."
    osascript -e 'tell application "Xcode" to activate' -e 'tell application "System Events" to keystroke "r" using command down'
    
    echo "🎉 应用正在Xcode中运行！"
    echo "📱 您可以在模拟器或连接的设备上看到'马夫'应用"
    
else
    echo "❌ 构建失败，请检查代码错误"
    exit 1
fi

echo "✨ 自动运行完成！"
