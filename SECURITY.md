# 🔒 安全最佳实践

## ✅ API Key 安全已修复

我们已经修复了所有 API key 泄漏问题！

### 修复内容
- ✅ `setup_openrouter.sh` 改为交互式输入（不再硬编码 key）
- ✅ `README_OPENROUTER.md` 使用占位符
- ✅ Git 历史已清理（不含任何真实 key）

---

## 🚨 重要：如果你已经推送到 GitHub

### 第 1 步：检查是否已推送

```bash
cd /Users/KakaYin/WorkSpace/Tools/claude-code-proxy-3/my-repro/claude-code-proxy
git log --oneline origin/main..HEAD
```

**如果显示空或错误**：说明你可能已经推送了，需要立即行动！

### 第 2 步：撤销 OpenRouter API Key

⚠️ **立即访问 OpenRouter 撤销这个 key：**

1. 登录 https://openrouter.ai/
2. 进入 "API Keys" 页面
3. 找到并**删除**可能泄漏的 key（如果存在）
4. 生成新的 key

### 第 3 步：更新本地配置

```bash
# 更新 .env 文件（使用新 key）
vi .env

# 更新 ~/.zshrc（使用新 key）
vi ~/.zshrc

# 重新加载
source ~/.zshrc
```

### 第 4 步：清理 GitHub 历史（如果已推送）

如果你已经推送包含 key 的提交到 GitHub，需要强制推送干净的历史：

```bash
cd /Users/KakaYin/WorkSpace/Tools/claude-code-proxy-3/my-repro/claude-code-proxy

# ⚠️ 警告：这会覆盖远程仓库的历史
git push --force origin main
```

---

## 🔐 API Key 安全最佳实践

### ✅ 正确做法

1. **使用环境变量**
   ```bash
   export OPENAI_API_KEY=your-key-here  # 只在本地 shell
   ```

2. **使用 .env 文件**
   ```bash
   # .env 文件（已在 .gitignore 中）
   OPENAI_API_KEY=your-key-here
   ```

3. **使用占位符**
   ```bash
   # 文档中
   OPENAI_API_KEY=sk-or-v1-YOUR-KEY-HERE
   ```

4. **交互式输入**
   ```bash
   read -p "API Key: " OPENROUTER_KEY
   ```

### ❌ 错误做法

1. ❌ **硬编码在脚本中**
   ```bash
   # 错误！
   API_KEY="sk-or-v1-real-key-here"
   ```

2. ❌ **硬编码在文档中**
   ```markdown
   # 错误！
   export API_KEY=sk-or-v1-real-key-here
   ```

3. ❌ **提交 .env 文件**
   ```bash
   # 错误！
   git add .env
   git commit -m "Add config"
   ```

---

## 📋 安全检查清单

在推送到 GitHub 之前，请确认：

- [ ] `.env` 文件在 `.gitignore` 中
- [ ] 没有硬编码的 API key 在任何文件中
- [ ] 所有文档使用占位符（如 `YOUR-KEY-HERE`）
- [ ] 脚本使用交互式输入或环境变量
- [ ] Git 历史中没有真实的 key

### 快速检查命令

```bash
# 检查当前文件
grep -r "sk-or-v1-" . --exclude-dir=.git

# 检查 Git 历史
git log -p | grep "sk-or-v1-"
```

如果有任何输出，说明存在 key 泄漏！

---

## 🆘 发现泄漏后的应急响应

1. **立即撤销受影响的 API key**
2. **生成新的 key**
3. **更新本地配置**
4. **清理 Git 历史**
5. **强制推送（如果已推送）**

---

## 📚 更多资源

- [GitHub: 移除敏感数据](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [OpenRouter: API Key 管理](https://openrouter.ai/keys)
- [Git: 重写历史](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)

---

## ✅ 当前状态

此仓库的当前状态：

- ✅ **代码安全** - 没有硬编码的 key
- ✅ **文档安全** - 使用占位符
- ✅ **Git 历史安全** - 已清理
- ✅ **未推送到 GitHub** - 本地修复完成

**可以安全推送！** 🚀

---

## 🙏 反馈

如果你发现任何安全问题，请立即报告！

