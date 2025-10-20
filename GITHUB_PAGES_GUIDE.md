# 🚀 GitHub Pages 部署指南 - 马夫应用支持页面

## 📋 快速开始

### 步骤1: 创建GitHub仓库
1. 访问 [GitHub.com](https://github.com)
2. 点击右上角的 "+" 按钮
3. 选择 "New repository"
4. 仓库名称建议: `mafu-support` 或 `mafu-app-support`
5. 设置为 **Public** (GitHub Pages免费版需要公开仓库)
6. 不要勾选 "Add a README file"
7. 点击 "Create repository"

### 步骤2: 上传文件
**方法A - 使用GitHub网页界面:**
1. 在新建的仓库页面，点击 "uploading an existing file"
2. 将项目中的 `index.html` 文件拖拽到上传区域
3. 将项目中的 `privacy-policy.html` 文件也拖拽到上传区域
4. 在底部填写提交信息: "Add support page and privacy policy for MaFu app"
5. 点击 "Commit changes"

**方法B - 使用Git命令行:**
```bash
# 在项目目录中执行
git init
git add index.html privacy-policy.html
git commit -m "Add support page and privacy policy for MaFu app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/mafu-support.git
git push -u origin main
```

### 步骤3: 启用GitHub Pages
1. 在仓库页面，点击 "Settings" 标签
2. 在左侧菜单中找到 "Pages"
3. 在 "Source" 下选择 "Deploy from a branch"
4. 选择 "main" 分支和 "/ (root)" 文件夹
5. 点击 "Save"
6. 等待几分钟，GitHub会显示您的页面URL

### 步骤4: 获取URL
您的页面URL格式为:
```
支持页面: https://YOUR_USERNAME.github.io/mafu-support
隐私政策: https://YOUR_USERNAME.github.io/mafu-support/privacy-policy.html
```

例如: 
- 支持页面: `https://tangxiaojun.github.io/mafu-support`
- 隐私政策: `https://tangxiaojun.github.io/mafu-support/privacy-policy.html`

## ⚙️ 配置Xcode项目

### 在Info.plist中添加URL
1. 在Xcode中打开项目
2. 选择项目 → Target → Info
3. 添加新的键值对:
   - **Key**: `CFBundleSupportURL`
   - **Value**: `https://YOUR_USERNAME.github.io/mafu-support`
   - **Key**: `NSPrivacyPolicyURL`
   - **Value**: `https://YOUR_USERNAME.github.io/mafu-support/privacy-policy.html`

### 或者直接编辑Info.plist文件
在 `Life/Info.plist` 中添加:
```xml
<key>CFBundleSupportURL</key>
<string>https://YOUR_USERNAME.github.io/mafu-support</string>
<key>NSPrivacyPolicyURL</key>
<string>https://YOUR_USERNAME.github.io/mafu-support/privacy-policy.html</string>
```

## 📱 验证部署

### 检查页面
1. 在浏览器中访问您的支持URL
2. 在浏览器中访问您的隐私政策URL
3. 确认页面正常显示
4. 检查移动端显示效果
5. 验证所有链接和内容

### 测试HTTPS
确保URL以 `https://` 开头，GitHub Pages默认提供HTTPS支持。

## 🔧 自定义支持页面

### 修改联系信息
编辑 `index.html` 文件中的联系信息:
```html
<div class="contact-item">
    <strong>邮箱:</strong>
    <span>your-email@example.com</span>
</div>
```

### 更新应用信息
修改版本号、应用描述等信息:
```html
<div class="info-card">
    <h3>版本</h3>
    <p>1.0.0</p>
</div>
```

## 📋 App Store Connect 配置

### 在App Store Connect中设置
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择您的应用
3. 在"应用信息"部分找到"支持URL"
4. 输入: `https://YOUR_USERNAME.github.io/mafu-support`
5. 保存更改

## ✅ 验证清单

部署完成后，请确认:
- [ ] GitHub仓库已创建
- [ ] index.html和privacy-policy.html已上传
- [ ] GitHub Pages已启用
- [ ] 支持页面可以正常访问
- [ ] 隐私政策页面可以正常访问
- [ ] URL使用HTTPS协议
- [ ] 页面在移动设备上显示正常
- [ ] Info.plist中已添加支持URL和隐私政策URL
- [ ] App Store Connect中已配置支持URL

## 🆘 常见问题

### Q: GitHub Pages没有显示页面
A: 检查文件名是否为 `index.html`，确保在仓库根目录

### Q: 页面显示404错误
A: 等待几分钟让GitHub Pages生效，或检查仓库设置

### Q: HTTPS证书问题
A: GitHub Pages自动提供HTTPS，确保URL以https://开头

### Q: 如何更新页面
A: 修改 `index.html` 或 `privacy-policy.html` 文件并重新提交到GitHub仓库

## 🎉 完成！

一旦完成上述步骤，您的支持页面和隐私政策页面就可以在App Store中使用了！

**URL示例**: 
- 支持页面: `https://tangxiaojun.github.io/mafu-support`
- 隐私政策: `https://tangxiaojun.github.io/mafu-support/privacy-policy.html`

记住将这些URL添加到您的Xcode项目和App Store Connect中。
