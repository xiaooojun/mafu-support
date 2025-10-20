# 📱 App Store Connect 图片使用指南

## 🎯 概述

已为您的"马夫"应用生成了符合App Store Connect要求的预览图和截屏。所有图片都基于您images文件夹下的真实图片资源创建，包括：

- **AppIcon.png** (1024×1024) - 应用图标
- **Calendar.png** (1024×1024) - 日历功能图标  
- **chart.png** (1024×1024) - 图表功能图标
- **dots.png** (1024×1024) - 点状功能图标

## 📁 生成的文件

### 📱 iPhone 6.7" 尺寸 (1242 × 2688px / 2688 × 1242px)
- `iphone_67_portrait_home_1.png` - 主界面截屏（竖屏）
- `iphone_67_portrait_feature_2.png` - 功能展示截屏（竖屏）
- `iphone_67_portrait_widget_3.png` - 小组件截屏（竖屏）
- `iphone_67_landscape_home_1.png` - 主界面截屏（横屏）
- `iphone_67_landscape_feature_2.png` - 功能展示截屏（横屏）
- `iphone_67_landscape_widget_3.png` - 小组件截屏（横屏）

### 📱 iPhone 6.1" 尺寸 (1284 × 2778px / 2778 × 1284px)
- `iphone_61_portrait_home_1.png` - 主界面截屏（竖屏）
- `iphone_61_portrait_feature_2.png` - 功能展示截屏（竖屏）
- `iphone_61_portrait_widget_3.png` - 小组件截屏（竖屏）
- `iphone_61_landscape_home_1.png` - 主界面截屏（横屏）
- `iphone_61_landscape_feature_2.png` - 功能展示截屏（横屏）
- `iphone_61_landscape_widget_3.png` - 小组件截屏（横屏）

## 🚀 App Store Connect 使用步骤

### 1. 登录 App Store Connect
访问 [App Store Connect](https://appstoreconnect.apple.com) 并登录您的开发者账户。

### 2. 选择您的应用
在"我的App"中找到"马夫"应用，点击进入。

### 3. 上传预览图和截屏

#### 📱 iPhone 预览图（最多3个）
1. 在"App信息"页面找到"预览图"部分
2. 选择"iPhone 6.7英寸显示屏"或"iPhone 6.1英寸显示屏"
3. 上传对应的横屏或竖屏预览图：
   - `iphone_67_portrait_home_1.png` 或 `iphone_61_portrait_home_1.png`
   - `iphone_67_portrait_feature_2.png` 或 `iphone_61_portrait_feature_2.png`
   - `iphone_67_portrait_widget_3.png` 或 `iphone_61_portrait_widget_3.png`

#### 📸 iPhone 截屏（最多10张）
1. 在"App信息"页面找到"截屏"部分
2. 选择对应的设备尺寸
3. 上传所有生成的截屏图片

### 4. 预览图建议
**推荐使用以下3张预览图：**
1. **主界面** - 展示应用的核心功能和界面设计
2. **功能展示** - 突出数据统计和情绪追踪功能
3. **小组件** - 展示桌面小组件的便利性

## 🎨 图片特点

### 🏠 主界面截屏
- **真实应用图标**：使用您的AppIcon.png作为应用图标
- **功能图标展示**：使用Calendar.png、chart.png、dots.png等真实图标
- **功能卡片布局**：清晰展示应用的核心功能
- **渐变背景设计**：专业的视觉效果

### 📊 功能展示截屏
- **真实图表**：使用您的chart.png图表图标
- **数据可视化**：展示情绪变化趋势
- **专业界面**：符合iOS设计规范

### 📱 小组件截屏
- **真实图标**：使用dots.png和chart.png图标
- **快速记录功能**：展示桌面小组件
- **今日统计信息**：直观的数据展示

## 📋 技术要求

### ✅ 符合要求
- **尺寸正确**：所有图片都符合Apple指定的尺寸要求
- **格式正确**：PNG格式，质量95%
- **内容相关**：基于您的实际应用功能设计
- **视觉统一**：使用一致的颜色主题和设计风格

### 🎯 设计亮点
- **真实图片**：使用您实际的应用图标和功能图标
- **渐变背景**：使用应用主题色创建视觉吸引力
- **手机框架**：真实的iPhone外观展示
- **功能突出**：清晰展示应用的核心功能
- **用户友好**：直观的界面布局和文字说明
- **专业品质**：符合App Store审核标准的高质量图片

## 🔧 自定义选项

如果您需要修改图片内容，可以：

1. **修改应用信息**：编辑 `create_advanced_app_store_images.py` 中的 `app_info` 部分
2. **调整颜色主题**：修改 `colors` 字典中的颜色值
3. **添加新功能**：在 `features` 列表中添加新的功能描述
4. **重新生成**：运行脚本重新生成所有图片

## 📞 支持

如果在App Store Connect上传过程中遇到问题：

1. **检查文件大小**：确保图片文件大小不超过Apple限制
2. **验证尺寸**：确认图片尺寸完全符合要求
3. **格式检查**：确保使用PNG格式
4. **内容审核**：确保图片内容符合App Store审核指南

## 🎉 完成！

现在您已经拥有了所有需要的App Store Connect图片，可以开始提交您的应用了！

**下一步：**
1. 上传预览图和截屏到App Store Connect
2. 填写应用描述和关键词
3. 设置价格和可用性
4. 提交审核

祝您的应用审核顺利！🚀
