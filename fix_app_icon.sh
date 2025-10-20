#!/bin/bash

# 应用图标透明度修复脚本
# 将RGBA格式的图标转换为RGB格式，去除透明度

echo "🔧 开始修复应用图标透明度问题..."

# 备份原始文件
echo "📦 备份原始图标文件..."
cp "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png" "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon_backup.png"
cp "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png" "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon_backup.png"

# 处理image文件夹中的AppIcon
echo "🖼️ 处理 image/AppIcon.imageset/AppIcon.png..."
sips -s format png -s formatOptions default "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png" --out "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon_temp.png"

# 创建白色背景并合成
sips -s format png -s formatOptions default "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon_temp.png" --padToHeightWidth 1024 1024 --padColor FFFFFF --out "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png"

# 处理logo文件夹中的AppIcon
echo "🖼️ 处理 logo/AppIcon.appiconset/AppIcon.png..."
sips -s format png -s formatOptions default "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png" --out "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon_temp.png"

# 创建白色背景并合成
sips -s format png -s formatOptions default "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon_temp.png" --padToHeightWidth 1024 1024 --padColor FFFFFF --out "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png"

# 清理临时文件
rm "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon_temp.png"
rm "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon_temp.png"

echo "✅ 图标修复完成！"
echo "📋 备份文件已保存为 *_backup.png"
echo "🔍 验证修复结果..."

# 验证修复结果
echo "image/AppIcon.imageset/AppIcon.png:"
file "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png"

echo "logo/AppIcon.appiconset/AppIcon.png:"
file "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png"
