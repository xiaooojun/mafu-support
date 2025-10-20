#!/bin/bash

# =============================================================================
# OpenWeatherMap API Key 配置脚本
# 请将 YOUR_API_KEY 替换为您的真实API Key
# =============================================================================

echo "🌤️ 配置OpenWeatherMap API Key..."

# 获取API Key
read -p "请输入您的OpenWeatherMap API Key: " API_KEY

if [ -z "$API_KEY" ]; then
    echo "❌ API Key不能为空"
    exit 1
fi

# 替换WeatherManager.swift中的API Key
sed -i '' "s/your_openweathermap_api_key/$API_KEY/g" Life/Utils/WeatherManager.swift

echo "✅ API Key配置完成！"
echo "📋 您可以在 https://openweathermap.org/api 获取免费的API Key"
echo "🔑 当前使用的API Key: $API_KEY"
