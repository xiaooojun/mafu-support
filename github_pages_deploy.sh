#!/bin/bash

# =============================================================================
# GitHub Pages 快速部署脚本
# =============================================================================

echo "🚀 GitHub Pages 快速部署脚本"
echo "====================================================="
echo ""

# 检查必要文件
if [ ! -f "index.html" ]; then
    echo "❌ 错误: 找不到 index.html 文件"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

echo "✅ 找到 index.html 文件"
echo ""

# 获取用户信息
read -p "请输入您的GitHub用户名: " github_username
read -p "请输入仓库名称 (建议: mafu-support): " repo_name

if [ -z "$github_username" ] || [ -z "$repo_name" ]; then
    echo "❌ 用户名和仓库名不能为空"
    exit 1
fi

# 生成支持URL
support_url="https://${github_username}.github.io/${repo_name}"
echo ""
echo "📋 您的支持页面URL将是:"
echo "🔗 $support_url"
echo ""

# 询问是否要初始化Git仓库
read -p "是否要初始化Git仓库并准备提交? (y/n): " init_git

if [ "$init_git" = "y" ] || [ "$init_git" = "Y" ]; then
    echo ""
    echo "🔧 初始化Git仓库..."
    
    # 检查是否已经是Git仓库
    if [ ! -d ".git" ]; then
        git init
        echo "✅ Git仓库已初始化"
    else
        echo "ℹ️  Git仓库已存在"
    fi
    
    # 添加文件
    git add index.html
    echo "✅ 已添加 index.html"
    
    # 提交
    git commit -m "Add support page for MaFu app"
    echo "✅ 已提交更改"
    
    # 设置远程仓库
    git remote add origin "https://github.com/${github_username}/${repo_name}.git" 2>/dev/null || {
        echo "ℹ️  远程仓库已存在，更新URL..."
        git remote set-url origin "https://github.com/${github_username}/${repo_name}.git"
    }
    
    echo "✅ 已设置远程仓库"
    echo ""
    echo "📋 下一步操作:"
    echo "1. 在GitHub上创建仓库: https://github.com/new"
    echo "2. 仓库名称: $repo_name"
    echo "3. 设置为 Public"
    echo "4. 不要添加 README、.gitignore 或 license"
    echo "5. 创建仓库后，运行以下命令推送代码:"
    echo ""
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    echo "6. 在仓库设置中启用 GitHub Pages"
    echo "7. 等待几分钟让页面生效"
    echo ""
else
    echo ""
    echo "📋 手动部署步骤:"
    echo "1. 在GitHub创建仓库: $repo_name"
    echo "2. 上传 index.html 文件"
    echo "3. 启用 GitHub Pages"
    echo "4. 访问: $support_url"
fi

echo ""
echo "⚙️  Xcode 配置:"
echo "在 Info.plist 中添加:"
echo "<key>CFBundleSupportURL</key>"
echo "<string>$support_url</string>"
echo ""

echo "📱 App Store Connect 配置:"
echo "支持URL: $support_url"
echo ""

echo "🎉 部署准备完成！"
echo "支持URL: $support_url"
echo ""

# 询问是否要打开GitHub创建页面
read -p "是否要打开GitHub创建仓库页面? (y/n): " open_github

if [ "$open_github" = "y" ] || [ "$open_github" = "Y" ]; then
    echo "🌐 正在打开GitHub..."
    open "https://github.com/new"
fi

echo ""
echo "📖 详细指南请查看: GITHUB_PAGES_GUIDE.md"
