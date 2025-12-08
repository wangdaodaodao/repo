#!/bin/bash

# 批量将 .dylib 文件打包成 arm64 .deb
# 自动处理指定目录下的所有 .dylib 文件

# set -e

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

# 查找所有 .dylib 和 .zip 文件
DYLIB_FILES=("$DYLIB_DIR"/*.dylib)
ZIP_FILES=("$DYLIB_DIR"/*.zip)

# 合并所有文件
ALL_FILES=("${DYLIB_FILES[@]}" "${ZIP_FILES[@]}")

if [ ! -e "${DYLIB_FILES[0]}" ] && [ ! -e "${ZIP_FILES[0]}" ]; then
    echo -e "${YELLOW}⚠️  未找到 .dylib 或 .zip 文件在 $DYLIB_DIR${NC}"
    exit 0
fi

TOTAL_FILES=${#ALL_FILES[@]}
echo -e "${GREEN}📦 找到 $TOTAL_FILES 个文件 (.dylib 和 .zip)${NC}"
echo ""

# 显示文件列表
for i in "${!ALL_FILES[@]}"; do
    echo "  $((i+1)). $(basename "${ALL_FILES[$i]}")"
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

# 处理 dylib 文件
for DYLIB_FILE in "${DYLIB_FILES[@]}"; do
    if [ ! -f "$DYLIB_FILE" ]; then
        continue
    fi
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
    elif [[ "$FILENAME" =~ "抖音" ]] || [[ "$FILENAME" =~ "TikTok" ]] || [[ "$FILENAME" =~ "Aweme" ]]; then
        BUNDLE_ID="com.ss.iphone.ugc.Aweme"
    elif [[ "$FILENAME" =~ "抖音极速" ]] || [[ "$FILENAME" =~ "TikTokLite" ]]; then
        BUNDLE_ID="com.ss.iphone.ugc.aweme.lite"
    elif [[ "$FILENAME" =~ "小红书" ]] || [[ "$FILENAME" =~ "xhs" ]]; then
        BUNDLE_ID="com.xingin.xhs"
    elif [[ "$FILENAME" =~ "微博" ]] || [[ "$FILENAME" =~ "Weibo" ]]; then
        BUNDLE_ID="com.sina.weibo"
    elif [[ "$FILENAME" =~ "Twitter" ]] || [[ "$FILENAME" =~ "推特" ]] || [[ "$FILENAME" =~ "X" ]]; then
        BUNDLE_ID="com.atebits.Tweetie2"
    elif [[ "$FILENAME" =~ "Instagram" ]] || [[ "$FILENAME" =~ "ins" ]] || [[ "$FILENAME" =~ "Ins" ]]; then
        BUNDLE_ID="com.burbn.instagram"
    elif [[ "$FILENAME" =~ "YouTube" ]] || [[ "$FILENAME" =~ "YT" ]]; then
        BUNDLE_ID="com.google.ios.youtube"
    elif [[ "$FILENAME" =~ "Spotify" ]] || [[ "$FILENAME" =~ "Eevee" ]]; then
        BUNDLE_ID="com.spotify.client"
    elif [[ "$FILENAME" =~ "Due" ]]; then
        BUNDLE_ID="com.phocusllp.due"
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

    # 复制 dylib 文件并设置可执行权限
    cp "$DYLIB_FILE" "$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/"
    chmod 755 "$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/$(basename "$DYLIB_FILE")"

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
Architecture: iphoneos-arm
Description: ${PACKAGE_NAME}
Maintainer: ${DEFAULT_AUTHOR}
Author: ${DEFAULT_AUTHOR}
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000)
EOF

    # 打包
    DEB_NAME="${PACKAGE_ID}_${DEFAULT_VERSION}_iphoneos-arm.deb"
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

# 处理 zip 文件
for ZIP_FILE in "${ZIP_FILES[@]}"; do
    if [ ! -f "$ZIP_FILE" ]; then
        continue
    fi

    FILENAME=$(basename "$ZIP_FILE" .zip)
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 处理 ZIP: $FILENAME (All-in-One 模式)${NC}"

    # 根据文件名智能推断包信息
    PACKAGE_ID="com.${DEFAULT_AUTHOR}.$(echo "$FILENAME" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')"
    PACKAGE_NAME="$FILENAME"

    # 智能推断目标应用
    BUNDLE_ID="com.apple.springboard"
    if [[ "$FILENAME" =~ "微信" ]] || [[ "$FILENAME" =~ "WeChat" ]]; then
        BUNDLE_ID="com.tencent.xin"
    elif [[ "$FILENAME" =~ "抖音" ]] || [[ "$FILENAME" =~ "TikTok" ]] || [[ "$FILENAME" =~ "Aweme" ]]; then
        BUNDLE_ID="com.ss.iphone.ugc.Aweme"
    elif [[ "$FILENAME" =~ "抖音极速" ]] || [[ "$FILENAME" =~ "TikTokLite" ]]; then
        BUNDLE_ID="com.ss.iphone.ugc.aweme.lite"
    elif [[ "$FILENAME" =~ "小红书" ]] || [[ "$FILENAME" =~ "xhs" ]]; then
        BUNDLE_ID="com.xingin.xhs"
    elif [[ "$FILENAME" =~ "微博" ]] || [[ "$FILENAME" =~ "Weibo" ]]; then
        BUNDLE_ID="com.sina.weibo"
    elif [[ "$FILENAME" =~ "Twitter" ]] || [[ "$FILENAME" =~ "推特" ]] || [[ "$FILENAME" =~ "X" ]]; then
        BUNDLE_ID="com.atebits.Tweetie2"
    elif [[ "$FILENAME" =~ "Instagram" ]] || [[ "$FILENAME" =~ "ins" ]] || [[ "$FILENAME" =~ "Ins" ]]; then
        BUNDLE_ID="com.burbn.instagram"
    elif [[ "$FILENAME" =~ "YouTube" ]] || [[ "$FILENAME" =~ "YT" ]]; then
        BUNDLE_ID="com.google.ios.youtube"
    elif [[ "$FILENAME" =~ "Spotify" ]] || [[ "$FILENAME" =~ "Eevee" ]]; then
        BUNDLE_ID="com.spotify.client"
    elif [[ "$FILENAME" =~ "Due" ]]; then
        BUNDLE_ID="com.phocusllp.due"
    elif [[ "$FILENAME" =~ "Reddit" ]] || [[ "$FILENAME" =~ "reddit" ]]; then
        BUNDLE_ID="com.reddit.Reddit"
    elif [[ "$FILENAME" =~ "高德" ]]; then
        BUNDLE_ID="com.autonavi.amap"
    elif [[ "$FILENAME" =~ "FLEX" ]]; then
        BUNDLE_ID="com.apple.springboard"
    fi

    echo "  Package ID: $PACKAGE_ID"
    echo "  Bundle ID: $BUNDLE_ID"

    # 创建临时目录
    TEMP_DIR="temp_${PACKAGE_ID}"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR/DEBIAN"
    
    # 建立标准目录结构 (Rootless /var/jb)
    DIR_DYLIB="$TEMP_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries"
    DIR_FRAMEWORKS="$TEMP_DIR/var/jb/Library/Frameworks"
    DIR_BUNDLES="$TEMP_DIR/var/jb/Library/PreferenceBundles"
    
    mkdir -p "$DIR_DYLIB"
    mkdir -p "$DIR_FRAMEWORKS"
    mkdir -p "$DIR_BUNDLES"

    # 解压 zip 文件到临时提取区
    EXTRACT_ROOT="temp_extract_${FILENAME}"
    rm -rf "$EXTRACT_ROOT"
    mkdir -p "$EXTRACT_ROOT"
    
    if unzip -q "$ZIP_FILE" -d "$EXTRACT_ROOT"; then
        echo "  解压成功，开始智能提取..."
    else
        echo -e "  ${RED}❌ 解压失败${NC}"
        ((FAILED_COUNT++))
        FAILED_FILES+=("$FILENAME")
        rm -rf "$TEMP_DIR"
        rm -rf "$EXTRACT_ROOT"
        continue
    fi

    # ─── 智能扁平化提取资源 ───
    
    HAS_CONTENT=false

    # 1. 查找并复制主 dylib (排除 framework 内部的 dylib)
    # find 查找所有 dylib
    # grep -v 排除路径中包含 framework 的情况 (简单过滤)
    FOUND_DYLIBS=$(find "$EXTRACT_ROOT" -name "*.dylib" | grep -v ".framework/" | grep -v ".bundle/" | grep -v "__MACOSX")
    
    if [ -n "$FOUND_DYLIBS" ]; then
        IFS=$'\n'
        for DYLIB_PATH in $FOUND_DYLIBS; do
            echo "    - 添加插件: $(basename "$DYLIB_PATH")"
            cp "$DYLIB_PATH" "$DIR_DYLIB/"
            chmod 755 "$DIR_DYLIB/$(basename "$DYLIB_PATH")"
            
            # 处理配套的 plist
            PLIST_SRC="${DYLIB_PATH%.dylib}.plist"
            if [ -f "$PLIST_SRC" ]; then
                cp "$PLIST_SRC" "$DIR_DYLIB/"
            else
                # 如果没有 plist，则自动生成一个
                DYLIB_BASE=$(basename "$DYLIB_PATH")
                PLIST_DEST="$DIR_DYLIB/${DYLIB_BASE%.dylib}.plist"
                cat > "$PLIST_DEST" << EOF
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
            fi
            HAS_CONTENT=true
        done
        IFS=$' \t\n'
    fi

    # 2. 查找并复制 Frameworks
    # 查找所有 .framework 目录，且它自己不是嵌套在另一个 framework 里 (简易判断)
    FOUND_FRAMEWORKS=$(find "$EXTRACT_ROOT" -name "*.framework" -type d | grep -v "__MACOSX")
    
    if [ -n "$FOUND_FRAMEWORKS" ]; then
        IFS=$'\n'
        for FW_PATH in $FOUND_FRAMEWORKS; do
            FW_NAME=$(basename "$FW_PATH")
            # 简单去重：如果目标目录已经有同名文件夹，可能是嵌套扫描到了，跳过
            if [ -d "$DIR_FRAMEWORKS/$FW_NAME" ]; then
                continue
            fi
            
            # 只有当父目录不是另一个 framework 时才复制 (避免复制 Framework 内部的子 Framework，通常 Framework 是独立的)
            # 或者更简单的：我们假设用户 zip 里的 framework 都是需要安装到 /Library/Frameworks 的
            if [[ "$FW_PATH" == *".framework/"*".framework" ]]; then
                continue
            fi
            
            echo "    - 添加框架: $FW_NAME"
            cp -R "$FW_PATH" "$DIR_FRAMEWORKS/"
        done
        IFS=$' \t\n'
    fi

    # 3. 查找并复制 Bundles (PreferenceBundles)
    FOUND_BUNDLES=$(find "$EXTRACT_ROOT" -name "*.bundle" -type d | grep -v "__MACOSX")
    
    if [ -n "$FOUND_BUNDLES" ]; then
        IFS=$'\n'
        for BUNDLE_PATH in $FOUND_BUNDLES; do
            BUNDLE_NAME=$(basename "$BUNDLE_PATH")
            if [ -d "$DIR_BUNDLES/$BUNDLE_NAME" ]; then continue; fi
            
            # 排除 Framework 内部的 bundle (资源包)
            if [[ "$BUNDLE_PATH" == *".framework/"* ]]; then
                continue
            fi
            
            echo "    - 添加资源包: $BUNDLE_NAME"
            cp -R "$BUNDLE_PATH" "$DIR_BUNDLES/"
        done
        IFS=$' \t\n'
    fi

    # 检查是否提取到了内容
    if [ "$HAS_CONTENT" = false ]; then
         echo -e "  ${RED}❌ ZIP 中未找到有效的 .dylib 文件${NC}"
        ((FAILED_COUNT++))
        FAILED_FILES+=("$FILENAME")
        rm -rf "$TEMP_DIR"
        rm -rf "$EXTRACT_ROOT"
        continue
    fi

    # 清理空目录 (如果某些目录没放东西，dpkg 也可以处理，但清理一下更干净)
    rmdir "$DIR_FRAMEWORKS" 2>/dev/null
    rmdir "$DIR_BUNDLES" 2>/dev/null


    # 创建 control 文件 (arm64架构)
    cat > "$TEMP_DIR/DEBIAN/control" << EOF
Package: ${PACKAGE_ID}
Name: ${PACKAGE_NAME}
Version: ${DEFAULT_VERSION}
Architecture: iphoneos-arm
Description: ${PACKAGE_NAME}
Maintainer: ${DEFAULT_AUTHOR}
Author: ${DEFAULT_AUTHOR}
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000)
EOF

    # 打包
    DEB_NAME="${PACKAGE_ID}_${DEFAULT_VERSION}_iphoneos-arm.deb"
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
    rm -rf "$EXTRACT_ROOT"
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
