# 越狱插件仓库源

这是一个托管在 GitHub Pages 上的 Cydia/Sileo 越狱插件仓库源。

## 📱 添加源地址

在 Cydia 或 Sileo 中添加以下源地址:

```
https://你的用户名.github.io/repo/
```

## 📦 如何添加插件

1. 将 `.deb` 文件放入 `debs/` 目录
2. 运行更新脚本生成索引文件
3. 提交并推送到 GitHub

## 🔧 本地构建

### 安装依赖 (macOS)

```bash
brew install dpkg
```

### 生成 Packages 文件

```bash
./update.sh
```

或手动执行:

```bash
dpkg-scanpackages -m debs /dev/null > Packages
bzip2 -fks Packages
```

## 📁 目录结构

```
repo/
├── debs/              # 存放所有 .deb 插件包
├── Packages           # 插件包索引文件(自动生成)
├── Packages.bz2       # 压缩的索引文件(自动生成)
├── Release            # 仓库信息文件
├── CydiaIcon.png      # 仓库图标(可选)
├── index.html         # 网页展示页面
└── update.sh          # 更新脚本
```

## 🚀 部署到 GitHub Pages

1. 创建 GitHub 仓库
2. 推送代码到仓库
3. 在仓库设置中启用 GitHub Pages
4. 选择 `main` 分支作为源
5. 访问 `https://你的用户名.github.io/仓库名/`

## ⚠️ 注意事项

- 确保你有权分发这些插件
- 不要上传盗版或破解的付费插件
- 遵守 GitHub 的使用条款
- 定期更新和维护仓库

## 📝 许可证

本仓库仅供学习交流使用。
