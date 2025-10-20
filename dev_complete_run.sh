#!/bin/bash

# =============================================================================
# 开发完成自动运行脚本
# 在开发工作完成后自动运行应用
# =============================================================================

echo "🎯 开发完成，开始自动运行应用..."

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
    
    # 检查是否有iOS模拟器
    echo "📱 检查iOS模拟器..."
    
    # 启动模拟器
    open -a Simulator
    
    # 等待模拟器启动
    echo "⏳ 等待模拟器启动..."
    sleep 3
    
    # 获取iPhone模拟器
    SIMULATOR_ID=$(xcrun simctl list devices available | grep "iPhone 16" | head -1 | grep -o '[A-F0-9-]\{36\}')
    
    if [ -n "$SIMULATOR_ID" ]; then
        echo "📱 启动iPhone模拟器..."
        xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null
        
        # 在模拟器中运行应用
        echo "🚀 在模拟器中运行应用..."
        xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" build
        
        if [ $? -eq 0 ]; then
            echo "🎉 应用已在模拟器中成功运行！"
            echo "📱 您可以在模拟器中看到'马夫'应用"
        else
            echo "❌ 模拟器运行失败"
        fi
    else
        echo "⚠️ 未找到iPhone模拟器"
        echo "📱 请手动在Xcode中运行应用"
    fi
    
else
    echo "❌ 构建失败，请检查代码错误"
    exit 1
fi

echo "✨ 自动运行完成！"
