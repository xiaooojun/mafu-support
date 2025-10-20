# 📱 马夫应用 - App Store 支持页面配置

## 🎯 概述

本文档说明如何为"马夫"应用配置App Store所需的支持信息URL。

## 📄 支持页面内容

已创建 `support.html` 文件，包含以下内容：
- 应用介绍和功能说明
- 常见问题解答
- 联系方式和支持信息
- 隐私政策和使用条款
- 应用版本和技术信息

## 🚀 部署选项

### 1. GitHub Pages (推荐 - 免费)

**步骤：**
1. 在GitHub创建新仓库，例如 `mafu-support`
2. 将 `support.html` 重命名为 `index.html`
3. 上传到仓库根目录
4. 在仓库设置中启用GitHub Pages
5. 访问：`https://yourusername.github.io/mafu-support`

**优点：** 免费、稳定、易于管理

### 2. Netlify (推荐 - 免费)

**步骤：**
1. 访问 [netlify.com](https://netlify.com)
2. 注册/登录账户
3. 拖拽 `support.html` 到部署区域
4. 获得类似：`https://amazing-name-123456.netlify.app`

**优点：** 免费、自动HTTPS、CDN加速

### 3. Vercel (推荐 - 免费)

**步骤：**
1. 访问 [vercel.com](https://vercel.com)
2. 注册/登录账户
3. 导入项目，上传 `support.html`
4. 获得类似：`https://mafu-support.vercel.app`

**优点：** 免费、快速部署、全球CDN

### 4. 自定义域名

**步骤：**
1. 购买域名，例如 `mafu-app.com`
2. 配置DNS指向您的服务器
3. 上传 `support.html` 到网站根目录
4. 确保支持HTTPS

**优点：** 专业、品牌化

## ⚙️ Xcode 配置

### 在 Xcode 中添加支持URL

1. **打开项目设置**
   - 选择项目 → Target → Info
   - 或直接编辑 `Info.plist` 文件

2. **添加支持URL**
   ```xml
   <key>CFBundleSupportURL</key>
   <string>https://your-support-url.com</string>
   ```

3. **其他必要配置**
   ```xml
   <key>CFBundleDisplayName</key>
   <string>马夫</string>
   
   <key>CFBundleShortVersionString</key>
   <string>1.0.0</string>
   
   <key>LSApplicationCategoryType</key>
   <string>public.app-category.lifestyle</string>
   ```

## 📋 App Store Connect 配置

### 在 App Store Connect 中设置

1. **登录 App Store Connect**
2. **选择您的应用**
3. **在"应用信息"部分**
   - 找到"支持URL"字段
   - 输入您的支持页面URL
4. **保存更改**

## 🔧 自动化脚本

使用提供的 `deploy_support.sh` 脚本：

```bash
chmod +x deploy_support.sh
./deploy_support.sh
```

脚本将引导您完成：
- 选择部署方式
- 获得支持URL
- 配置Info.plist

## ✅ 验证清单

部署完成后，请确认：

- [ ] 支持页面可以正常访问
- [ ] 页面支持HTTPS（必需）
- [ ] 页面在移动设备上显示正常
- [ ] 联系信息准确无误
- [ ] Info.plist中已添加支持URL
- [ ] App Store Connect中已配置支持URL

## 📞 联系信息模板

支持页面中的联系信息可以根据需要修改：

```html
<div class="contact-item">
    <strong>邮箱:</strong>
    <span>support@mafu-app.com</span>
</div>
<div class="contact-item">
    <strong>反馈:</strong>
    <span>feedback@mafu-app.com</span>
</div>
```

## 🎨 自定义样式

支持页面使用响应式设计，可以根据需要自定义：
- 颜色主题
- 字体样式
- 布局结构
- 添加Logo

## 📱 移动端优化

支持页面已针对移动设备优化：
- 响应式布局
- 触摸友好的按钮
- 快速加载
- 清晰的字体大小

## 🔒 隐私合规

支持页面包含：
- 隐私政策说明
- 数据使用说明
- 用户权利说明
- 联系方式

## 🚀 快速开始

1. **选择部署方式**（推荐GitHub Pages）
2. **部署支持页面**
3. **获得支持URL**
4. **配置Xcode项目**
5. **提交到App Store**

---

**注意：** 确保支持URL在应用提交前可以正常访问，Apple会验证这个URL的有效性。
