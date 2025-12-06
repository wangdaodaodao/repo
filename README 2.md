# debs 目录

这个目录用于存放所有的 `.deb` 越狱插件包。

## 📦 如何添加插件

1. 将 `.deb` 文件直接放入此目录
2. 运行 `./update.sh` 更新索引
3. 提交并推送到 GitHub

## 📝 .deb 包命名规范

建议使用以下命名格式:

```
包名_版本号_架构.deb
```

例如:
- `com.example.tweak_1.0.0_iphoneos-arm.deb`
- `com.myrepo.app_2.1.5_iphoneos-arm64.deb`

## 🔧 如何制作 .deb 包

如果你需要制作自己的 .deb 包,可以参考以下工具:

- **Theos**: iOS 越狱开发框架
- **dpkg-deb**: Debian 包构建工具

### 基本 .deb 包结构

```
package/
├── DEBIAN/
│   └── control          # 包信息文件
└── Library/
    └── MobileSubstrate/
        └── DynamicLibraries/
            ├── Tweak.dylib
            └── Tweak.plist
```

### control 文件示例

```
Package: com.example.tweak
Name: My Tweak
Version: 1.0.0
Architecture: iphoneos-arm
Description: 这是一个示例插件
Maintainer: Your Name <your@email.com>
Author: Your Name
Section: Tweaks
Depends: mobilesubstrate
```

## ⚠️ 注意事项

- 确保 .deb 包是有效的
- 检查包的依赖关系
- 测试插件是否正常工作
- 不要上传恶意代码或盗版内容
