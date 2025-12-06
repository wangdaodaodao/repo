#!/bin/bash

# .dylib 文件打包成 .deb 脚本
# 用法: ./pack-dylib.sh <dylib文件路径>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ 错误: 请提供 .dylib 文件路径${NC}"
    echo "用法: ./pack-dylib.sh <dylib文件路径>"
    echo "示例: ./pack-dylib.sh debs/微信助手_3.8-7.dylib"
    exit 1
fi

DYLIB_FILE="$1"

# 检查文件是否存在
if [ ! -f "$DYLIB_FILE" ]; then
    echo -e "${RED}❌ 错误: 文件不存在: $DYLIB_FILE${NC}"
    exit 1
fi

# 检查文件扩展名
if [[ ! "$DYLIB_FILE" =~ \.dylib$ ]]; then
    echo -e "${RED}❌ 错误: 文件必须是 .dylib 格式${NC}"
    exit 1
fi

# 获取文件名(不含路径和扩展名)
FILENAME=$(basename "$DYLIB_FILE" .dylib)
echo -e "${BLUE}📦 开始打包: $FILENAME${NC}"

# 提示用户输入包信息
echo ""
echo -e "${YELLOW}请输入包信息(直接回车使用默认值):${NC}"
echo ""

read -p "Package ID (例如: com.author.tweak) [默认: com.wangdaodao.${FILENAME}]: " PACKAGE_ID
PACKAGE_ID=${PACKAGE_ID:-"com.wangdaodao.${FILENAME}"}

read -p "包名称 (例如: 微信助手) [默认: ${FILENAME}]: " PACKAGE_NAME
PACKAGE_NAME=${PACKAGE_NAME:-"${FILENAME}"}

read -p "版本号 (例如: 1.0.0) [默认: 1.0.0]: " VERSION
VERSION=${VERSION:-"1.0.0"}

read -p "作者 (例如: Your Name) [默认: wangdaodao]: " AUTHOR
AUTHOR=${AUTHOR:-"wangdaodao"}

read -p "描述 (例如: 微信增强插件) [默认: ${PACKAGE_NAME}]: " DESCRIPTION
DESCRIPTION=${DESCRIPTION:-"${PACKAGE_NAME}"}

read -p "目标应用 Bundle ID (例如: com.tencent.xin) [默认: com.apple.springboard]: " BUNDLE_ID
BUNDLE_ID=${BUNDLE_ID:-"com.apple.springboard"}

# 创建临时目录
TEMP_DIR="temp_${PACKAGE_ID}"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo ""
echo -e "${BLUE}📁 创建包结构...${NC}"

# 创建目录结构
mkdir -p "$TEMP_DIR/DEBIAN"
mkdir -p "$TEMP_DIR/Library/MobileSubstrate/DynamicLibraries"

# 复制 dylib 文件
cp "$DYLIB_FILE" "$TEMP_DIR/Library/MobileSubstrate/DynamicLibraries/"

# 创建 plist 文件
DYLIB_NAME=$(basename "$DYLIB_FILE")
PLIST_FILE="$TEMP_DIR/Library/MobileSubstrate/DynamicLibraries/${DYLIB_NAME%.dylib}.plist"

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Filter</key>
    <dict>
        <key>Bundles</key>
        <array>
            <string>${BUNDLE_ID}</string>
        </array>
    </dict>
</dict>
</plist>
EOF

echo -e "${GREEN}✅ 已创建 plist 文件${NC}"

# 创建 control 文件
cat > "$TEMP_DIR/DEBIAN/control" << EOF
Package: ${PACKAGE_ID}
Name: ${PACKAGE_NAME}
Version: ${VERSION}
Architecture: iphoneos-arm
Description: ${DESCRIPTION}
Maintainer: ${AUTHOR}
Author: ${AUTHOR}
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000)
EOF

echo -e "${GREEN}✅ 已创建 control 文件${NC}"

# 打包成 .deb
DEB_NAME="${PACKAGE_ID}_${VERSION}_iphoneos-arm.deb"
OUTPUT_PATH="debs/${DEB_NAME}"

echo ""
echo -e "${BLUE}🔨 开始打包...${NC}"

# 使用 dpkg-deb 打包
dpkg-deb -b "$TEMP_DIR" "$OUTPUT_PATH" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 打包成功!${NC}"
    echo ""
    echo -e "${GREEN}📦 输出文件: $OUTPUT_PATH${NC}"
    echo -e "${GREEN}📊 文件大小: $(ls -lh "$OUTPUT_PATH" | awk '{print $5}')${NC}"
    
    # 清理临时目录
    rm -rf "$TEMP_DIR"
    
    echo ""
    echo -e "${YELLOW}💡 下一步操作:${NC}"
    echo "   1. 运行 ./update.sh 更新索引"
    echo "   2. git add . && git commit -m '添加 ${PACKAGE_NAME}'"
    echo "   3. git push"
    
else
    echo -e "${RED}❌ 打包失败${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi
