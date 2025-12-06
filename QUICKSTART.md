# ⚡ 快速开始指南

## 📋 当前状态

✅ 仓库结构已创建完成  
✅ 所有必需文件已生成  
✅ Git 仓库已初始化  
⏳ 等待推送到 GitHub  

## 🎯 下一步操作

### 1️⃣ 推送到 GitHub

```bash
# 在 GitHub 上创建一个新仓库后,执行以下命令:

# 添加远程仓库(替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/repo.git

# 推送代码
git push -u origin main
```

### 2️⃣ 启用 GitHub Pages

1. 进入 GitHub 仓库的 **Settings** → **Pages**
2. Source 选择 `main` 分支,目录选择 `/ (root)`
3. 点击 **Save**
4. 等待 1-3 分钟部署完成

### 3️⃣ 获取你的源地址

部署完成后,你的源地址将是:
```
https://YOUR_USERNAME.github.io/repo/
```

### 4️⃣ 在 Cydia/Sileo 中添加源

1. 打开 Cydia 或 Sileo
2. 进入"软件源"
3. 点击"添加"
4. 输入你的源地址
5. 完成!

## 📦 如何添加插件

### 方法 A: 本地添加

```bash
# 1. 将 .deb 文件放入 debs 目录
cp /path/to/your-plugin.deb debs/

# 2. 更新索引(需要先安装 dpkg: brew install dpkg)
./update.sh

# 3. 提交并推送
git add .
git commit -m "添加插件: your-plugin"
git push
```

### 方法 B: GitHub 网页上传

1. 访问 GitHub 仓库
2. 进入 `debs` 目录
3. 点击 **Add file** → **Upload files**
4. 上传 `.deb` 文件
5. 提交更改
6. GitHub Actions 会自动更新索引

## 📁 目录结构说明

```
repo/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions 自动化配置
├── debs/                      # 存放 .deb 插件包
│   ├── .gitkeep              # 保持目录被 Git 跟踪
│   └── README.md             # debs 目录说明
├── .gitignore                # Git 忽略文件
├── CydiaIcon.png             # 仓库图标
├── DEPLOYMENT.md             # 详细部署指南
├── index.html                # 网页展示页面
├── Packages                  # 插件索引(自动生成)
├── Packages.bz2              # 压缩索引(自动生成)
├── README.md                 # 项目说明
├── Release                   # 仓库信息文件
└── update.sh                 # 本地更新脚本
```

## 🔧 自定义配置

### 修改仓库信息

编辑 `Release` 文件:

```bash
Origin: 你的仓库名称           # 在 Cydia 中显示的名称
Label: 你的仓库标签            # 仓库标签
Description: 你的仓库描述      # 仓库描述
```

### 更换仓库图标

替换 `CydiaIcon.png` 文件(建议尺寸: 512x512 或 1024x1024)

## 📚 相关文档

- **README.md** - 项目概述和基本使用
- **DEPLOYMENT.md** - 详细的部署步骤和常见问题
- **debs/README.md** - 如何制作和添加 .deb 包

## ⚠️ 重要提醒

1. **合法性**: 只分发你有权分发的插件
2. **安全性**: 不要上传恶意代码或病毒
3. **版权**: 尊重原作者的版权
4. **测试**: 上传前测试插件是否正常工作

## 🆘 需要帮助?

- 查看 `DEPLOYMENT.md` 获取详细部署指南
- 检查 GitHub Actions 标签页查看构建状态
- 确保 GitHub Pages 已正确启用

---

**准备好了吗?** 现在就去 GitHub 创建仓库并推送代码吧! 🚀
