#!/usr/bin/env python3

import os
from PIL import Image

def fix_app_icon_transparency():
    """修复应用图标透明度问题"""
    
    print("🔧 开始修复应用图标透明度问题...")
    
    # 图标文件路径
    icon_paths = [
        "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png",
        "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png"
    ]
    
    for icon_path in icon_paths:
        if os.path.exists(icon_path):
            print(f"🖼️ 处理 {icon_path}...")
            
            # 备份原始文件
            backup_path = icon_path.replace('.png', '_backup.png')
            os.system(f"cp '{icon_path}' '{backup_path}'")
            
            # 打开图像
            img = Image.open(icon_path)
            
            # 检查是否有alpha通道
            if img.mode in ('RGBA', 'LA'):
                print(f"  - 检测到alpha通道，正在去除...")
                
                # 创建白色背景
                background = Image.new('RGB', img.size, (255, 255, 255))
                
                # 如果是RGBA，直接合成
                if img.mode == 'RGBA':
                    background.paste(img, mask=img.split()[-1])  # 使用alpha通道作为mask
                else:  # LA模式
                    background.paste(img, mask=img.split()[-1])
                
                # 保存为RGB格式
                background.save(icon_path, 'PNG')
                print(f"  - 已转换为RGB格式")
            else:
                print(f"  - 图像已经是RGB格式，无需处理")
            
            # 验证结果
            result_img = Image.open(icon_path)
            print(f"  - 最终格式: {result_img.mode}")
    
    print("✅ 图标修复完成！")

if __name__ == "__main__":
    fix_app_icon_transparency()
