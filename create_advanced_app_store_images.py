#!/usr/bin/env python3
"""
App Store Connect 高级预览图和截屏生成器
生成更真实的应用界面截屏
"""

import os
from PIL import Image, ImageDraw, ImageFont
import textwrap
import random
import math

class AdvancedAppStoreImageGenerator:
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
                {"icon": "📝", "title": "事项记录", "desc": "记录日常事务和重要事件"},
                {"icon": "😊", "title": "情绪追踪", "desc": "记录心情变化和情绪状态"},
                {"icon": "📊", "title": "数据统计", "desc": "查看趋势分析和数据报告"},
                {"icon": "🌤️", "title": "天气信息", "desc": "获取当地天气信息"},
                {"icon": "📱", "title": "小组件", "desc": "桌面小组件快速记录"}
            ]
        }
        
        # 颜色主题
        self.colors = {
            "primary": "#667eea",
            "secondary": "#764ba2", 
            "background": "#f8f9ff",
            "card_bg": "#ffffff",
            "text": "#333333",
            "light_text": "#666666",
            "accent": "#4CAF50"
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

    def hex_to_rgb(self, hex_color):
        """将十六进制颜色转换为RGB"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    def create_gradient_background(self, size, color1, color2, direction='vertical'):
        """创建渐变背景"""
        width, height = size
        image = Image.new('RGB', size, color1)
        draw = ImageDraw.Draw(image)
        
        if direction == 'vertical':
            for y in range(height):
                ratio = y / height
                r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
                g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
                b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
                draw.line([(0, y), (width, y)], fill=(r, g, b))
        else:  # horizontal
            for x in range(width):
                ratio = x / width
                r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
                g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
                b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
                draw.line([(x, 0), (x, height)], fill=(r, g, b))
        
        return image

    def add_text(self, image, text, position, font_size, color, max_width=None, align='center'):
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
                
                if align == 'center':
                    x = position[0] - text_width // 2 if position[0] > 0 else position[0]
                elif align == 'left':
                    x = position[0]
                else:  # right
                    x = position[0] - text_width
                
                draw.text((x, position[1] + y_offset), line, font=font, fill=color)
                y_offset += text_height + 5
        else:
            draw.text(position, text, font=font, fill=color)

    def create_phone_frame(self, image, is_landscape=False):
        """创建手机框架"""
        width, height = image.size
        
        if is_landscape:
            phone_width = min(width * 0.7, height * 0.9)
            phone_height = phone_width * 0.55
        else:
            phone_height = min(height * 0.8, width * 0.5)
            phone_width = phone_height * 0.5
        
        # 手机位置居中
        phone_x = (width - phone_width) // 2
        phone_y = (height - phone_height) // 2
        
        return int(phone_x), int(phone_y), int(phone_width), int(phone_height)

    def create_home_screen(self, image, images, is_landscape=False):
        """创建主界面截屏"""
        width, height = image.size
        draw = ImageDraw.Draw(image)
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_phone_frame(image, is_landscape)
        
        # 绘制手机外框
        phone_color = (30, 30, 30)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=25, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 15
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=20, fill=screen_bg)
        
        # 状态栏
        status_height = 40
        draw.rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + status_height], 
                      fill=(0, 0, 0))
        
        # 状态栏内容
        self.add_text(image, "9:41", (screen_x + screen_width - 50, screen_y + 15), 
                     16, (255, 255, 255))
        
        # 应用标题区域
        title_area_y = screen_y + status_height + 20
        title_height = 80
        
        # 标题背景
        title_bg = self.hex_to_rgb(self.colors["primary"])
        draw.rounded_rectangle([screen_x + 20, title_area_y, screen_x + screen_width - 20, title_area_y + title_height], 
                             radius=15, fill=title_bg)
        
        # 应用名称
        self.add_text(image, self.app_info["name"], 
                     (screen_x + screen_width // 2, title_area_y + 20), 
                     28, (255, 255, 255))
        
        # 副标题
        self.add_text(image, self.app_info["subtitle"], 
                     (screen_x + screen_width // 2, title_area_y + 50), 
                     16, (255, 255, 255, 180))
        
        # 功能卡片区域
        cards_start_y = title_area_y + title_height + 30
        card_height = 70
        card_spacing = 15
        
        for i, feature in enumerate(self.app_info["features"][:4]):
            card_x = screen_x + 20
            card_width = screen_width - 40
            card_y = cards_start_y + i * (card_height + card_spacing)
            
            # 卡片背景
            draw.rounded_rectangle([card_x, card_y, card_x + card_width, card_y + card_height], 
                                 radius=12, fill=self.hex_to_rgb(self.colors["card_bg"]))
            
            # 卡片阴影效果
            shadow_offset = 2
            draw.rounded_rectangle([card_x + shadow_offset, card_y + shadow_offset, 
                                  card_x + card_width + shadow_offset, card_y + card_height + shadow_offset], 
                                 radius=12, fill=(0, 0, 0, 30))
            
            # 功能图标
            icon_size = 30
            icon_x = card_x + 20
            icon_y = card_y + (card_height - icon_size) // 2
            
            # 图标背景
            icon_bg = self.hex_to_rgb(self.colors["primary"])
            draw.rounded_rectangle([icon_x - 5, icon_y - 5, icon_x + icon_size + 5, icon_y + icon_size + 5], 
                                 radius=8, fill=icon_bg)
            
            # 功能文字
            text_x = icon_x + icon_size + 15
            text_y = card_y + card_height // 2
            
            self.add_text(image, feature["title"], (text_x, text_y - 10), 
                         18, self.hex_to_rgb(self.colors["text"]), align='left')
            self.add_text(image, feature["desc"], (text_x, text_y + 10), 
                         14, self.hex_to_rgb(self.colors["light_text"]), align='left')

    def create_feature_screen(self, image, images, is_landscape=False):
        """创建功能展示截屏"""
        width, height = image.size
        draw = ImageDraw.Draw(image)
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_phone_frame(image, is_landscape)
        
        # 绘制手机外框
        phone_color = (30, 30, 30)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=25, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 15
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=20, fill=screen_bg)
        
        # 状态栏
        status_height = 40
        draw.rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + status_height], 
                      fill=(0, 0, 0))
        
        # 页面标题
        page_title_y = screen_y + status_height + 30
        self.add_text(image, "📊 数据统计", 
                     (screen_x + screen_width // 2, page_title_y), 
                     24, self.hex_to_rgb(self.colors["text"]))
        
        # 图表区域
        chart_y = page_title_y + 60
        chart_height = 200
        chart_width = screen_width - 40
        
        # 图表背景
        draw.rounded_rectangle([screen_x + 20, chart_y, screen_x + 20 + chart_width, chart_y + chart_height], 
                             radius=15, fill=self.hex_to_rgb(self.colors["card_bg"]))
        
        # 模拟图表数据
        chart_data = [65, 80, 45, 90, 75, 85, 70]
        bar_width = chart_width // len(chart_data) - 10
        max_height = chart_height - 40
        
        for i, value in enumerate(chart_data):
            bar_height = int((value / 100) * max_height)
            bar_x = screen_x + 20 + i * (bar_width + 10) + 20
            bar_y = chart_y + chart_height - bar_height - 20
            
            # 绘制柱状图
            bar_color = self.hex_to_rgb(self.colors["primary"])
            draw.rounded_rectangle([bar_x, bar_y, bar_x + bar_width, chart_y + chart_height - 20], 
                                 radius=5, fill=bar_color)
        
        # 功能说明
        desc_y = chart_y + chart_height + 30
        self.add_text(image, "查看您的情绪变化趋势", 
                     (screen_x + screen_width // 2, desc_y), 
                     16, self.hex_to_rgb(self.colors["light_text"]))

    def create_widget_screen(self, image, images, is_landscape=False):
        """创建小组件截屏"""
        width, height = image.size
        draw = ImageDraw.Draw(image)
        
        # 手机框架
        phone_x, phone_y, phone_width, phone_height = self.create_phone_frame(image, is_landscape)
        
        # 绘制手机外框
        phone_color = (30, 30, 30)
        draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_width, phone_y + phone_height], 
                             radius=25, fill=phone_color)
        
        # 手机屏幕
        screen_margin = 15
        screen_x = phone_x + screen_margin
        screen_y = phone_y + screen_margin
        screen_width = phone_width - screen_margin * 2
        screen_height = phone_height - screen_margin * 2
        
        # 屏幕背景
        screen_bg = self.hex_to_rgb(self.colors["background"])
        draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + screen_height], 
                             radius=20, fill=screen_bg)
        
        # 状态栏
        status_height = 40
        draw.rectangle([screen_x, screen_y, screen_x + screen_width, screen_y + status_height], 
                      fill=(0, 0, 0))
        
        # 小组件展示
        widget_y = screen_y + status_height + 50
        
        # 小组件1 - 快速记录
        widget1_width = screen_width - 40
        widget1_height = 100
        
        draw.rounded_rectangle([screen_x + 20, widget_y, screen_x + 20 + widget1_width, widget_y + widget1_height], 
                             radius=15, fill=self.hex_to_rgb(self.colors["card_bg"]))
        
        self.add_text(image, "📝 快速记录", 
                     (screen_x + 20 + 20, widget_y + 20), 
                     18, self.hex_to_rgb(self.colors["text"]), align='left')
        
        self.add_text(image, "点击记录当前心情", 
                     (screen_x + 20 + 20, widget_y + 50), 
                     14, self.hex_to_rgb(self.colors["light_text"]), align='left')
        
        # 小组件2 - 今日统计
        widget2_y = widget_y + widget1_height + 20
        widget2_height = 80
        
        draw.rounded_rectangle([screen_x + 20, widget2_y, screen_x + 20 + widget1_width, widget2_y + widget2_height], 
                             radius=15, fill=self.hex_to_rgb(self.colors["card_bg"]))
        
        self.add_text(image, "📊 今日统计", 
                     (screen_x + 20 + 20, widget2_y + 15), 
                     18, self.hex_to_rgb(self.colors["text"]), align='left')
        
        self.add_text(image, "已记录 5 个事项", 
                     (screen_x + 20 + 20, widget2_y + 45), 
                     14, self.hex_to_rgb(self.colors["light_text"]), align='left')

    def create_app_screenshot(self, size, images, screenshot_type="home"):
        """创建应用截屏"""
        width, height = size
        is_landscape = width > height
        
        # 创建背景
        bg_color1 = self.hex_to_rgb(self.colors["primary"])
        bg_color2 = self.hex_to_rgb(self.colors["secondary"])
        image = self.create_gradient_background(size, bg_color1, bg_color2, 
                                              'horizontal' if is_landscape else 'vertical')
        
        if screenshot_type == "home":
            self.create_home_screen(image, images, is_landscape)
        elif screenshot_type == "feature":
            self.create_feature_screen(image, images, is_landscape)
        elif screenshot_type == "widget":
            self.create_widget_screen(image, images, is_landscape)
        
        return image

    def generate_all_images(self):
        """生成所有需要的图片"""
        print("开始生成高级App Store Connect图片...")
        
        # 加载现有图片
        images = self.load_images()
        print(f"加载了 {len(images)} 张图片")
        
        # 截屏类型
        screenshot_types = ["home", "feature", "widget"]
        
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
    generator = AdvancedAppStoreImageGenerator()
    generator.generate_all_images()

if __name__ == "__main__":
    main()
