# OpenRouter 快速配置（60秒）

## 1️⃣ 配置 .env

```bash
# 复制并编辑
cp .env.example .env

# 设置你的 OpenRouter API key
OPENAI_API_KEY=sk-or-v1-你的密钥
OPENAI_BASE_URL=https://openrouter.ai/api/v1

# OpenRouter 必需的 headers
CUSTOM_HEADER_HTTP_REFERER=
CUSTOM_HEADER_X_TITLE=

# 使用 Claude 4.5 系列
BIG_MODEL=anthropic/claude-opus-4.5
MIDDLE_MODEL=anthropic/claude-sonnet-4.5
SMALL_MODEL=anthropic/claude-haiku-4.5
```

## 2️⃣ 配置 Shell（~/.zshrc）

```bash
export ANTHROPIC_AUTH_TOKEN=sk-or-v1-你的密钥
export ANTHROPIC_BASE_URL=http://127.0.0.1:8082
```

然后：
```bash
source ~/.zshrc
```

## 3️⃣ 启动

```bash
python start_proxy.py
```

## 4️⃣ 使用

```bash
claude
```

---

## ✅ 验证

```bash
# 检查代理状态
curl http://127.0.0.1:8082/health

# 查看模型配置
curl http://127.0.0.1:8082/ | jq '.config'
```

---

## 📚 详细文档

查看 `OPENROUTER_GUIDE.md` 了解：
- 完整的故障排查
- 其他模型配置
- 工作原理说明

