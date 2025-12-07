#!/bin/bash

# 批量将 .dylib 文件打包成 arm64 .deb
# 自动处理指定目录下的所有 .dylib 文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   批量 .dylib 转 arm64 .deb 打包工具  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}用法: $0 <dylib目录>${NC}"
    echo -e "${YELLOW}例如: $0 dylib${NC}"
    exit 1
fi

DYLIB_DIR="$1"

# 查找所有 .dylib 文件
DYLIB_FILES=("$DYLIB_DIR"/*.dylib)

if [ ! -e "${DYLIB_FILES[0]}" ]; then
    echo -e "${YELLOW}⚠️  未找到 .dylib 文件在 $DYLIB_DIR${NC}"
    exit 0
fi

TOTAL_FILES=${#DYLIB_FILES[@]}
echo -e "${GREEN}📦 找到 $TOTAL_FILES 个 .dylib 文件${NC}"
echo ""

# 显示文件列表
for i in "${!DYLIB_FILES[@]}"; do
    echo "  $((i+1)). $(basename "${DYLIB_FILES[$i]}")"
done

echo ""
# 使用命令行参数或默认值
DEFAULT_AUTHOR=${2:-"wangdaodao"}
DEFAULT_VERSION=${3:-"1.0.0"}
CONFIRM="y"

echo -e "${YELLOW}使用配置:${NC}"
echo "  作者: $DEFAULT_AUTHOR"
echo "  版本: $DEFAULT_VERSION"
echo ""

echo ""
echo -e "${BLUE}开始批量打包 arm64...${NC}"
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_FILES=()

# 处理每个文件
for DYLIB_FILE in "${DYLIB_FILES[@]}"; do
    FILENAME=$(basename "$DYLIB_FILE" .dylib)
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 处理: $FILENAME${NC}"

    # 根据文件名智能推断包信息
    PACKAGE_ID="com.${DEFAULT_AUTHOR}.$(echo "$FILENAME" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')"
    PACKAGE_NAME="$FILENAME"

    # 智能推断目标应用
    BUNDLE_ID="com.apple.springboard"
    if [[ "$FILENAME" =~ "微信" ]] || [[ "$FILENAME" =~ "WeChat" ]]; then
        BUNDLE_ID="com.tencent.xin"
    elif [[ "$FILENAME" =~ "抖音" ]] || [[ "$FILENAME" =~ "TikTok" ]]; then
        BUNDLE_ID="com.ss.iphone.ugc.Aweme"
    elif [[ "$FILENAME" =~ "小红书" ]] || [[ "$FILENAME" =~ "xhs" ]]; then
        BUNDLE_ID="com.xingin.xhs"
    elif [[ "$FILENAME" =~ "微博" ]] || [[ "$FILENAME" =~ "Weibo" ]]; then
        BUNDLE_ID="com.sina.weibo"
    elif [[ "$FILENAME" =~ "高德" ]]; then
        BUNDLE_ID="com.autonavi.amap"
    fi

    echo "  Package ID: $PACKAGE_ID"
    echo "  Bundle ID: $BUNDLE_ID"

    # 创建临时目录
    TEMP_DIR="temp_${PACKAGE_ID}"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR/DEBIAN"
    mkdir -p "$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries"

    # 复制 dylib 文件
    cp "$DYLIB_FILE" "$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/"

    # 创建 plist 文件
    DYLIB_NAME=$(basename "$DYLIB_FILE")
    PLIST_FILE="$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/${DYLIB_NAME%.dylib}.plist"

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

    # 创建 control 文件 (arm64架构)
    cat > "$TEMP_DIR/DEBIAN/control" << EOF
Package: ${PACKAGE_ID}
Name: ${PACKAGE_NAME}
Version: ${DEFAULT_VERSION}
Architecture: iphoneos-arm64
Description: ${PACKAGE_NAME}
Maintainer: ${DEFAULT_AUTHOR}
Author: ${DEFAULT_AUTHOR}
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000)
EOF

    # 打包
    DEB_NAME="${PACKAGE_ID}_${DEFAULT_VERSION}_iphoneos-arm64.deb"
    OUTPUT_PATH="debs/${DEB_NAME}"

    if dpkg-deb -b "$TEMP_DIR" "$OUTPUT_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 成功: $DEB_NAME${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${RED}❌ 失败${NC}"
        ((FAILED_COUNT++))
        FAILED_FILES+=("$FILENAME")
    fi

    # 清理
    rm -rf "$TEMP_DIR"
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 arm64打包完成!${NC}"
echo ""
echo -e "  ${GREEN}✅ 成功: $SUCCESS_COUNT 个${NC}"
echo -e "  ${RED}❌ 失败: $FAILED_COUNT 个${NC}"

if [ $FAILED_COUNT -gt 0 ]; then
    echo ""
    echo -e "${RED}失败的文件:${NC}"
    for file in "${FAILED_FILES[@]}"; do
        echo "  - $file"
    done
fi

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 下一步操作:${NC}"
    echo "   1. 运行 ./update.sh 更新索引"
    echo "   2. git add . && git commit -m '添加arm64插件'"
    echo "   3. git push"
fi
