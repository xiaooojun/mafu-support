#!/bin/bash

# =============================================================================
# 自动运行应用脚本
# 在开发完成后自动启动应用
# =============================================================================

echo "🚀 开始自动运行应用..."

# 检查是否在正确的目录
if [ ! -f "Life.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 清理构建缓存
echo "🧹 清理构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Life-*
rm -rf build

# 构建应用
echo "🔨 构建应用..."
xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "generic/platform=iOS" build

if [ $? -eq 0 ]; then
    echo "✅ 构建成功！"
    
    # 检查是否有连接的iOS设备
    echo "📱 检查连接的设备..."
    DEVICES=$(xcrun xctrace list devices | grep "iPhone\|iPad" | grep -v "Simulator")
    
    if [ -n "$DEVICES" ]; then
        echo "发现连接的设备："
        echo "$DEVICES"
        
        # 获取第一个设备的UDID
        DEVICE_UDID=$(echo "$DEVICES" | head -1 | grep -o '[A-F0-9-]\{36\}')
        
        if [ -n "$DEVICE_UDID" ]; then
            echo "📲 在设备上安装并运行应用..."
            xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "id=$DEVICE_UDID" build
            
            if [ $? -eq 0 ]; then
                echo "✅ 应用已安装到设备！"
                echo "📱 请在设备上手动启动应用"
            else
                echo "❌ 设备安装失败"
            fi
        else
            echo "⚠️ 无法获取设备UDID"
        fi
    else
        echo "📱 未发现连接的设备，启动模拟器..."
        
        # 启动iOS模拟器
        open -a Simulator
        
        # 等待模拟器启动
        echo "⏳ 等待模拟器启动..."
        sleep 5
        
        # 获取可用的模拟器
        SIMULATORS=$(xcrun simctl list devices available | grep "iPhone\|iPad")
        if [ -n "$SIMULATORS" ]; then
            echo "可用的模拟器："
            echo "$SIMULATORS"
            
            # 使用第一个iPhone模拟器
            SIMULATOR_ID=$(echo "$SIMULATORS" | grep "iPhone" | head -1 | grep -o '[A-F0-9-]\{36\}')
            
            if [ -n "$SIMULATOR_ID" ]; then
                echo "📱 启动模拟器并运行应用..."
                xcrun simctl boot "$SIMULATOR_ID"
                
                # 构建并运行
                xcodebuild -project Life.xcodeproj -scheme Life -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" build
                
                if [ $? -eq 0 ]; then
                    echo "✅ 应用已在模拟器中运行！"
                else
                    echo "❌ 模拟器运行失败"
                fi
            else
                echo "❌ 无法找到可用的模拟器"
            fi
        else
            echo "❌ 没有可用的模拟器"
        fi
    fi
    
else
    echo "❌ 构建失败！"
    echo "请检查代码错误并重试"
    exit 1
fi

echo "🎉 自动运行完成！"
