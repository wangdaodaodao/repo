# 🚀 GitHub Pages 部署指南

按照以下步骤将你的越狱插件仓库部署到 GitHub Pages。

## 步骤 1: 创建 GitHub 仓库

1. 访问 [GitHub](https://github.com)
2. 点击右上角的 `+` 号,选择 `New repository`
3. 填写仓库信息:
   - **Repository name**: `repo` (或其他你喜欢的名称)
   - **Description**: `iOS 越狱插件仓库源`
   - **Public**: 选择公开(必须是公开仓库才能使用 GitHub Pages)
   - **不要**勾选 "Initialize this repository with a README"
4. 点击 `Create repository`

## 步骤 2: 推送代码到 GitHub

在终端中执行以下命令:

```bash
# 添加远程仓库(替换 YOUR_USERNAME 为你的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/repo.git

# 推送代码
git push -u origin main
```

如果你的默认分支是 `master` 而不是 `main`,使用:

```bash
git branch -M main
git push -u origin main
```

## 步骤 3: 启用 GitHub Pages

1. 进入你的 GitHub 仓库页面
2. 点击 `Settings` (设置)
3. 在左侧菜单中找到 `Pages`
4. 在 `Source` 部分:
   - **Branch**: 选择 `main`
   - **Folder**: 选择 `/ (root)`
5. 点击 `Save`

## 步骤 4: 等待部署完成

- GitHub 会自动部署你的网站
- 通常需要 1-3 分钟
- 部署完成后,你会看到一个绿色的提示框,显示你的网站地址:
  ```
  Your site is published at https://YOUR_USERNAME.github.io/repo/
  ```

## 步骤 5: 更新 index.html 中的源地址

部署完成后,你需要修改 `Release` 文件中的仓库信息:

1. 编辑 `Release` 文件
2. 将 `Origin` 和 `Label` 改为你想要的名称
3. 提交并推送更改

## 步骤 6: 测试仓库源

### 在浏览器中测试

访问你的仓库地址:
```
https://YOUR_USERNAME.github.io/repo/
```

你应该能看到漂亮的仓库展示页面。

### 在 Cydia/Sileo 中测试

1. 打开 Cydia 或 Sileo
2. 添加源: `https://YOUR_USERNAME.github.io/repo/`
3. 刷新源列表
4. 如果没有错误,说明仓库配置成功!

## 添加插件

### 方法 1: 本地添加(推荐)

```bash
# 1. 将 .deb 文件放入 debs 目录
cp your-tweak.deb debs/

# 2. 运行更新脚本
./update.sh

# 3. 提交并推送
git add .
git commit -m "添加新插件: your-tweak"
git push
```

### 方法 2: 直接在 GitHub 上传

1. 进入 GitHub 仓库页面
2. 点击 `debs` 目录
3. 点击 `Add file` → `Upload files`
4. 拖拽 `.deb` 文件上传
5. 填写提交信息并提交
6. GitHub Actions 会自动更新 Packages 文件

## 自动化说明

本仓库已配置 GitHub Actions,当你推送 `.deb` 文件到 `debs/` 目录时:

1. 自动运行 `dpkg-scanpackages` 生成 Packages 文件
2. 自动压缩生成 Packages.bz2
3. 自动提交更新

你可以在仓库的 `Actions` 标签页查看构建状态。

## 自定义域名(可选)

如果你有自己的域名,可以配置自定义域名:

1. 在仓库根目录创建 `CNAME` 文件
2. 文件内容填写你的域名,如: `repo.yourdomain.com`
3. 在你的域名 DNS 设置中添加 CNAME 记录:
   ```
   repo.yourdomain.com → YOUR_USERNAME.github.io
   ```
4. 在 GitHub Pages 设置中填写自定义域名

## 常见问题

### Q: 404 错误
A: 确保 GitHub Pages 已启用,并且选择了正确的分支和目录。

### Q: Packages 文件没有更新
A: 检查 GitHub Actions 是否运行成功,或手动运行 `./update.sh`。

### Q: Cydia 无法添加源
A: 确保源地址以 `/` 结尾,如: `https://username.github.io/repo/`

### Q: 需要安装 dpkg 吗?
A: 本地开发需要,但 GitHub Actions 会自动处理,无需本地安装。

安装方法(macOS):
```bash
brew install dpkg
```

## 维护建议

- 定期检查插件是否有更新
- 及时删除过时或有问题的插件
- 保持 README 和 Release 信息更新
- 监控 GitHub Actions 构建状态

---

🎉 恭喜!你的越狱插件仓库源已经成功部署!
