#!/usr/bin/env python3
"""
App Store Connect 预览图和截屏生成器
根据现有的应用图标和功能图片，生成符合Apple要求的预览图和截屏
"""

import os
from PIL import Image, ImageDraw, ImageFont
import textwrap
import random

class AppStoreImageGenerator:
    def __init__(self):
        self.base_path = "/Users/tangxiaojun/Downloads/Life/Life/Assets.xcassets/image"
        self.output_path = "/Users/tangxiaojun/Downloads/Life/AppStoreImages"
        
        # 创建输出目录
        os.makedirs(self.output_path, exist_ok=True)
        
        # App Store Connect 要求的尺寸
        self.sizes = {
            "iphone_67_portrait": (1242, 2688),    # iPhone 6.7" 竖屏
            "iphone_67_landscape": (2688, 1242),    # iPhone 6.7" 横屏
            "iphone_61_portrait": (1284, 2778),     # iPhone 6.1" 竖屏
            "iphone_61_landscape": (2778, 1284),    # iPhone 6.1" 横屏
        }
        
        # 应用信息
        self.app_info = {
            "name": "马夫",
            "subtitle": "生活记录与情绪管理",
            "description": "记录生活点滴，管理情绪变化",
            "features": [
                "📝 事项记录",
                "😊 情绪追踪", 
                "📊 数据统计",
                "🌤️ 天气信息",
                "📱 小组件支持"
            ]
        }
        
        # 颜色主题
        self.colors = {
            "primary": "#667eea",
            "secondary": "#764ba2", 
            "background": "#f8f9ff",
            "text": "#333333",
            "light_text": "#666666"
        }

    def load_images(self):
        """加载现有的应用图片"""
        images = {}
        
        # 加载应用图标
        app_icon_path = os.path.join(self.base_path, "AppIcon.imageset", "AppIcon.png")
        if os.path.exists(app_icon_path):
            images["app_icon"] = Image.open(app_icon_path)
        
        # 加载功能图标
        icon_files = ["Calendar.png", "chart.png", "dots.png"]
        for icon_file in icon_files:
            icon_path = os.path.join(self.base_path, f"{icon_file.split('.')[0]}.imageset", icon_file)
            if os.path.exists(icon_path):
                images[icon_file.split('.')[0]] = Image.open(icon_path)
        
        return images

    def create_gradient_background(self, size, color1, color2):
        """创建渐变背景"""
        width, height = size
        image = Image.new('RGB', size, color1)
        draw = ImageDraw.Draw(image)
        
        # 创建渐变效果
        for y in range(height):
            ratio = y / height
            r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
            g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
            b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
            draw.line([(0, y), (width, y)], fill=(r, g, b))
        
        return image

    def hex_to_rgb(self, hex_color):
        """将十六进制颜色转换为RGB"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    def add_text(self, image, text, position, font_size, color, max_width=None):
        """在图片上添加文字"""
        draw = ImageDraw.Draw(image)
        
        try:
            # 尝试使用系统字体
            font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", font_size)
        except:
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
            except:
                font = ImageFont.load_default()
        
        if max_width:
            # 自动换行
            lines = textwrap.wrap(text, width=max_width)
            y_offset = 0
            for line in lines:
                bbox = draw.textbbox((0, 0), line, font=font)
                text_width = bbox[2] - bbox[0]
                text_height = bbox[3] - bbox[1]
                
                x = position[0] - text_width // 2 if position[0] > 0 else position[0]
                draw.text((x, position[1] + y_offset), line, font=font, fill=color)
                y_offset += text_height + 5
        else:
            draw.text(position, text, font=font, fill=color)

    def create_mockup_phone(self, size, is_landscape=False):
        """创建手机框架"""
        width, height = size
        
        if is_landscape:
            phone_width = min(width * 0.6, height * 0.8)
            phone_height = phone_width * 1.8
        else:
            phone_height = min(height * 0.7, width * 0.4)
            phone_width = phone_height * 0.5
        
        # 手机位置居中
        phone_x = (width - phone_width) // 2
        phone_y = (height - phone_height) // 2
        
        return int(phone_x), int(phone_y), int(phone_width), int(phone_height)

    def create_app_screenshot(self, size, images, screenshot_type="main"):
        """创建应用截屏"""
        width, height = size
        is_landscape = width > height
        
        # 创建背景
        bg_color1 = self.hex_to_rgb(self.colors["primary"])
        bg_color2 = self.hex_to_rgb(self.colors["secondary"])
        image = self.create_gradient_background(size, bg_color1, bg_color2)
        
        if screenshot_type == "main":
            # 主界面截屏
            self.create_main_screenshot(image, images, is_landscape)
        elif screenshot_type == "features":
            # 功能展示截屏
            self.create_features_screenshot(image, images, is_landscape)
        elif screenshot_type == "widget":
            # 小组件截屏
            self.create_widget_screenshot(image, images, is_landscape)
        
        return image

    def create_main_screenshot(self, image, images, is_landscape):
        """创建主界面截屏"""
        width, height = image.size
        draw = ImageDraw.Draw(image)
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_mockup_phone((width, height), is_landscape)
        
        # 绘制手机外框
        phone_color = (50, 50, 50)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=20, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 10
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=15, fill=screen_bg)
        
        # 状态栏
        status_height = 30
        draw.rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + status_height], 
                      fill=(0, 0, 0))
        
        # 应用标题
        title_y = screen_y + status_height + 20
        self.add_text(image, self.app_info["name"], 
                     (screen_x + screen_width // 2, title_y), 
                     24, self.hex_to_rgb(self.colors["text"]))
        
        # 副标题
        subtitle_y = title_y + 40
        self.add_text(image, self.app_info["subtitle"], 
                     (screen_x + screen_width // 2, subtitle_y), 
                     16, self.hex_to_rgb(self.colors["light_text"]))
        
        # 功能卡片
        card_y = subtitle_y + 60
        card_height = 80
        card_spacing = 20
        
        for i, feature in enumerate(self.app_info["features"][:3]):
            card_x = screen_x + 20
            card_width = screen_width - 40
            
            # 卡片背景
            draw.rounded_rectangle([card_x, card_y + i * (card_height + card_spacing), 
                                  card_x + card_width, card_y + i * (card_height + card_spacing) + card_height], 
                                 radius=10, fill=(255, 255, 255))
            
            # 功能文字
            self.add_text(image, feature, 
                         (card_x + 20, card_y + i * (card_height + card_spacing) + card_height // 2), 
                         18, self.hex_to_rgb(self.colors["text"]))

    def create_features_screenshot(self, image, images, is_landscape):
        """创建功能展示截屏"""
        width, height = image.size
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_mockup_phone((width, height), is_landscape)
        
        # 绘制手机外框
        phone_color = (50, 50, 50)
        draw = ImageDraw.Draw(image)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=20, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 10
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=15, fill=screen_bg)
        
        # 功能图标展示
        if "Calendar" in images:
            icon_size = 60
            icon_x = screen_x + screen_width // 2 - icon_size // 2
            icon_y = screen_y + 100
            
            # 调整图标大小
            calendar_icon = images["Calendar"].resize((icon_size, icon_size), Image.Resampling.LANCZOS)
            image.paste(calendar_icon, (icon_x, icon_y), calendar_icon if calendar_icon.mode == 'RGBA' else None)
        
        # 功能描述
        desc_y = screen_y + 200
        self.add_text(image, "📊 数据统计", 
                     (screen_x + screen_width // 2, desc_y), 
                     20, self.hex_to_rgb(self.colors["text"]))

    def create_widget_screenshot(self, image, images, is_landscape):
        """创建小组件截屏"""
        width, height = image.size
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_mockup_phone((width, height), is_landscape)
        
        # 绘制手机外框
        phone_color = (50, 50, 50)
        draw = ImageDraw.Draw(image)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=20, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 10
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=15, fill=screen_bg)
        
        # 小组件展示
        widget_y = screen_y + 100
        self.add_text(image, "📱 小组件支持", 
                     (screen_x + screen_width // 2, widget_y), 
                     20, self.hex_to_rgb(self.colors["text"]))

    def generate_all_images(self):
        """生成所有需要的图片"""
        print("开始生成App Store Connect图片...")
        
        # 加载现有图片
        images = self.load_images()
        print(f"加载了 {len(images)} 张图片")
        
        # 截屏类型
        screenshot_types = ["main", "features", "widget"]
        
        for size_name, size in self.sizes.items():
            print(f"生成尺寸: {size_name} ({size[0]}x{size[1]})")
            
            for i, screenshot_type in enumerate(screenshot_types):
                # 创建截屏
                screenshot = self.create_app_screenshot(size, images, screenshot_type)
                
                # 保存文件
                filename = f"{size_name}_{screenshot_type}_{i+1}.png"
                filepath = os.path.join(self.output_path, filename)
                screenshot.save(filepath, "PNG", quality=95)
                print(f"  保存: {filename}")
        
        print(f"\n所有图片已生成到: {self.output_path}")
        print("\n生成的文件:")
        for file in sorted(os.listdir(self.output_path)):
            if file.endswith('.png'):
                filepath = os.path.join(self.output_path, file)
                file_size = os.path.getsize(filepath) / 1024 / 1024  # MB
                print(f"  {file} ({file_size:.1f}MB)")

def main():
    generator = AppStoreImageGenerator()
    generator.generate_all_images()

if __name__ == "__main__":
    main()
