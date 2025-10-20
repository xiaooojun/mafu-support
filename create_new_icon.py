#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon():
    """创建一个新的应用图标"""
    
    print("🎨 创建新的应用图标...")
    
    # 图标尺寸
    size = 1024
    
    # 创建白色背景的图像
    img = Image.new('RGB', (size, size), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # 定义颜色
    primary_color = (52, 152, 219)  # 蓝色
    secondary_color = (46, 204, 113)  # 绿色
    accent_color = (241, 196, 15)    # 黄色
    
    # 绘制圆形背景
    margin = 50
    circle_size = size - 2 * margin
    draw.ellipse([margin, margin, margin + circle_size, margin + circle_size], 
                fill=primary_color, outline=None)
    
    # 绘制内部装饰
    inner_margin = 150
    inner_size = size - 2 * inner_margin
    
    # 绘制心形图标
    heart_points = []
    center_x, center_y = size // 2, size // 2
    heart_scale = 200
    
    # 心形路径
    for angle in range(0, 360, 5):
        rad = math.radians(angle)
        # 心形公式
        x = center_x + heart_scale * (16 * math.sin(rad)**3)
        y = center_y - heart_scale * (13 * math.cos(rad) - 5 * math.cos(2*rad) - 2 * math.cos(3*rad) - math.cos(4*rad))
        heart_points.append((x, y))
    
    if heart_points:
        draw.polygon(heart_points, fill=(255, 255, 255))
    
    # 添加文字 "马夫"
    try:
        # 尝试使用系统字体
        font_size = 120
        font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            font = ImageFont.load_default()
    
    text = "马夫"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2 + 50  # 稍微向下偏移
    
    # 绘制文字阴影
    draw.text((text_x + 3, text_y + 3), text, font=font, fill=(0, 0, 0, 100))
    # 绘制文字
    draw.text((text_x, text_y), text, font=font, fill=(255, 255, 255))
    
    # 添加装饰性元素
    # 绘制小圆点装饰
    dot_positions = [
        (200, 200), (824, 200), (200, 824), (824, 824),
        (300, 300), (724, 300), (300, 724), (724, 724)
    ]
    
    for pos in dot_positions:
        draw.ellipse([pos[0]-10, pos[1]-10, pos[0]+10, pos[1]+10], 
                    fill=accent_color)
    
    return img

def replace_app_icons():
    """替换应用图标文件"""
    
    print("🔄 替换应用图标文件...")
    
    # 创建新图标
    new_icon = create_app_icon()
    
    # 图标文件路径
    icon_paths = [
        "Life/Assets.xcassets/image/AppIcon.imageset/AppIcon.png",
        "Life/Assets.xcassets/logo/AppIcon.appiconset/AppIcon.png"
    ]
    
    for icon_path in icon_paths:
        print(f"📁 创建 {icon_path}...")
        # 确保目录存在
        os.makedirs(os.path.dirname(icon_path), exist_ok=True)
        # 保存新图标
        new_icon.save(icon_path, 'PNG')
        print(f"✅ 已创建")
    
    print("🎉 应用图标替换完成！")

if __name__ == "__main__":
    replace_app_icons()
