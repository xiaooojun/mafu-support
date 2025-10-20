#!/bin/bash

# =============================================================================
# App Store 支持页面部署脚本
# =============================================================================

echo "====================================================="
echo "  马夫应用 - App Store 支持页面部署"
echo "====================================================="
echo ""

# 检查支持页面文件是否存在
if [ ! -f "support.html" ]; then
    echo "❌ 错误: 找不到 support.html 文件"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

echo "📄 支持页面文件已准备就绪"
echo ""

# 显示部署选项
echo "请选择部署方式："
echo "1. GitHub Pages (推荐 - 免费)"
echo "2. Netlify (推荐 - 免费)"
echo "3. Vercel (推荐 - 免费)"
echo "4. 自定义域名"
echo "5. 仅显示配置信息"
echo ""

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🚀 GitHub Pages 部署指南："
        echo "1. 在 GitHub 创建新仓库 (例如: mafu-support)"
        echo "2. 将 support.html 重命名为 index.html"
        echo "3. 上传到仓库根目录"
        echo "4. 在仓库设置中启用 GitHub Pages"
        echo "5. 访问: https://yourusername.github.io/mafu-support"
        echo ""
        echo "📝 配置 Info.plist 支持URL:"
        echo "https://yourusername.github.io/mafu-support"
        ;;
    2)
        echo ""
        echo "🚀 Netlify 部署指南："
        echo "1. 访问 https://netlify.com"
        echo "2. 注册/登录账户"
        echo "3. 拖拽 support.html 到部署区域"
        echo "4. 获得类似: https://amazing-name-123456.netlify.app"
        echo ""
        echo "📝 配置 Info.plist 支持URL:"
        echo "https://amazing-name-123456.netlify.app"
        ;;
    3)
        echo ""
        echo "🚀 Vercel 部署指南："
        echo "1. 访问 https://vercel.com"
        echo "2. 注册/登录账户"
        echo "3. 导入项目，上传 support.html"
        echo "4. 获得类似: https://mafu-support.vercel.app"
        echo ""
        echo "📝 配置 Info.plist 支持URL:"
        echo "https://mafu-support.vercel.app"
        ;;
    4)
        echo ""
        echo "🌐 自定义域名部署："
        echo "1. 购买域名 (例如: mafu-app.com)"
        echo "2. 配置 DNS 指向您的服务器"
        echo "3. 上传 support.html 到网站根目录"
        echo "4. 确保支持 HTTPS"
        echo ""
        echo "📝 配置 Info.plist 支持URL:"
        echo "https://mafu-app.com/support"
        ;;
    5)
        echo ""
        echo "📋 当前配置信息："
        echo "应用名称: 马夫"
        echo "版本: 1.0.0"
        echo "类别: 生活方式"
        echo "支持页面: support.html"
        echo ""
        echo "📝 需要在 Info.plist 中添加的配置："
        echo "• CFBundleDisplayName: 马夫"
        echo "• CFBundleShortVersionString: 1.0.0"
        echo "• LSApplicationCategoryType: public.app-category.lifestyle"
        echo "• 支持URL: [您的部署URL]"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "📋 下一步操作："
echo "1. 按照上述指南部署支持页面"
echo "2. 获得支持页面的URL"
echo "3. 在 Xcode 中配置支持URL"
echo "4. 提交应用到 App Store"
echo ""

# 询问是否要自动配置 Info.plist
read -p "是否要自动配置 Info.plist 支持URL? (y/n): " auto_config

if [ "$auto_config" = "y" ] || [ "$auto_config" = "Y" ]; then
    read -p "请输入您的支持页面URL: " support_url
    
    if [ -n "$support_url" ]; then
        # 这里可以添加自动配置 Info.plist 的逻辑
        echo "✅ 支持URL已记录: $support_url"
        echo "请手动在 Xcode 项目设置中添加此URL"
    else
        echo "❌ URL不能为空"
    fi
fi

echo ""
echo "🎉 部署准备完成！"
echo "支持页面文件: support.html"
echo "请按照上述指南完成部署"
