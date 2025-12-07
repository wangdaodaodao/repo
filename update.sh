#!/bin/bash

# 越狱插件仓库更新脚本
# 用于生成 Packages 索引文件

echo "🔄 开始更新仓库索引..."

# 检查 dpkg-scanpackages 是否安装
if ! command -v dpkg-scanpackages &> /dev/null; then
    echo "❌ 错误: dpkg-scanpackages 未安装"
    echo "请运行: brew install dpkg"
    exit 1
fi

# 检查 debs 目录是否存在
if [ ! -d "debs" ]; then
    echo "⚠️  警告: debs 目录不存在,正在创建..."
    mkdir -p debs
fi

# 检查 debs 目录是否为空
if [ -z "$(ls -A debs)" ]; then
    echo "⚠️  警告: debs 目录为空,没有插件需要索引"
    echo "请将 .deb 文件放入 debs/ 目录"
fi

# 生成 Packages 文件
echo "📦 生成 Packages 文件..."
dpkg-scanpackages -m debs /dev/null | sed 's|Filename: /Users/wangdaodao/编程/repo/|Filename: |g' > Packages 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Packages 文件生成成功"
else
    echo "❌ Packages 文件生成失败"
    exit 1
fi

# 压缩 Packages 文件
echo "🗜️  压缩 Packages 文件..."
bzip2 -fks Packages

if [ $? -eq 0 ]; then
    echo "✅ Packages.bz2 生成成功"
else
    echo "❌ 压缩失败"
    exit 1
fi

# 显示统计信息
PACKAGE_COUNT=$(grep -c "^Package:" Packages 2>/dev/null || echo "0")
echo ""
echo "📊 更新完成!"
echo "   - 插件数量: $PACKAGE_COUNT"
echo "   - Packages 大小: $(ls -lh Packages | awk '{print $5}')"
echo "   - Packages.bz2 大小: $(ls -lh Packages.bz2 | awk '{print $5}')"
echo ""
echo "💡 提示: 现在可以提交并推送到 GitHub"
echo "   git add ."
echo "   git commit -m \"更新插件索引\""
echo "   git push"
