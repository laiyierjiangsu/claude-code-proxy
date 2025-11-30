# OpenRouter 配置指南

本指南说明如何配置 claude-code-proxy 以使用 OpenRouter API。

## 🎯 快速开始

### 1. 配置 .env 文件

```bash
cp .env .env.backup  # 备份（如果已存在）

# 编辑 .env 文件
OPENAI_API_KEY=sk-or-v1-你的OpenRouter密钥
OPENAI_BASE_URL=https://openrouter.ai/api/v1

# OpenRouter 必需的 headers
CUSTOM_HEADER_HTTP_REFERER=
CUSTOM_HEADER_X_TITLE=

# 模型配置
BIG_MODEL=anthropic/claude-opus-4.5
MIDDLE_MODEL=anthropic/claude-sonnet-4.5
SMALL_MODEL=anthropic/claude-haiku-4.5
```

### 2. 配置 Shell 环境变量

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Claude Code with OpenRouter
export ANTHROPIC_AUTH_TOKEN=sk-or-v1-你的OpenRouter密钥
export ANTHROPIC_BASE_URL=http://127.0.0.1:8082
```

**注意**：
- ✅ 使用 `ANTHROPIC_AUTH_TOKEN`（不是 `ANTHROPIC_API_KEY`）
- ✅ 不要设置 `ANTHROPIC_MODEL`（让代理自动映射）

然后执行：
```bash
source ~/.zshrc
```

### 3. 启动代理

```bash
python start_proxy.py
```

### 4. 使用 Claude Code

```bash
claude
```

---

## 📝 核心修改说明

### 修改的文件：只有 1 个！

**`src/__init__.py`** - 确保 .env 优先于系统环境变量

```python
from pathlib import Path
from dotenv import load_dotenv

# 关键：使用 override=True
project_root = Path(__file__).parent.parent
env_path = project_root / '.env'
load_dotenv(dotenv_path=env_path, override=True)
```

---

## 🌟 OpenRouter 支持的 Claude 模型

查询 OpenRouter 支持的所有 Claude 模型：

```bash
curl -s https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY" \
  | jq '.data[] | select(.id | contains("claude")) | .id'
```

**当前可用的 Claude 4.5 系列**：
- `anthropic/claude-opus-4.5` - 最强推理
- `anthropic/claude-sonnet-4.5` - 平衡性能
- `anthropic/claude-haiku-4.5` - 快速响应

**Claude 3.x 系列**：
- `anthropic/claude-3-opus`
- `anthropic/claude-3.5-sonnet`
- `anthropic/claude-3-haiku`

---

## 🔧 其他模型配置示例

### 使用 GPT 系列
```bash
BIG_MODEL=openai/gpt-4o
MIDDLE_MODEL=openai/gpt-4o
SMALL_MODEL=openai/gpt-4o-mini
```

### 使用 Google Gemini
```bash
BIG_MODEL=google/gemini-pro-1.5
MIDDLE_MODEL=google/gemini-flash-1.5
SMALL_MODEL=google/gemini-flash-1.5-8b
```

### 混合使用
```bash
BIG_MODEL=anthropic/claude-opus-4.5
MIDDLE_MODEL=openai/gpt-4o
SMALL_MODEL=google/gemini-flash-1.5
```

---

## 🐛 故障排查

### 问题 1: Invalid API key
**症状**: Claude Code 显示 "Invalid API key"

**解决方案**:
1. 确认使用 `ANTHROPIC_AUTH_TOKEN`（不是 `ANTHROPIC_API_KEY`）
2. 重启 Claude Code
3. 检查代理是否运行：`curl http://127.0.0.1:8082/health`

### 问题 2: 400 - Model not found
**症状**: OpenRouter 返回模型不存在

**解决方案**:
1. 查询 OpenRouter 支持的模型列表
2. 使用正确的模型 ID（如 `anthropic/claude-opus-4.5`）
3. 不要使用带日期的格式（如 `claude-opus-4-20250514`）

### 问题 3: 工具调用不工作
**症状**: Web Search 等工具不被调用

**原因**: 模型选择不调用工具（正常行为）

**解决方案**:
- 使用更强的模型（Opus > Sonnet > Haiku）
- 提问更明确需要实时数据的问题

### 问题 4: 系统环境变量冲突
**症状**: .env 配置不生效

**解决方案**:
- 确认 `src/__init__.py` 有 `override=True`
- 检查系统环境变量：`env | grep OPENAI`
- 必要时使用 `unset OPENAI_API_KEY`

---

## 📊 工作原理

### 请求流程

```
Claude Code 
  ↓ (Claude API 格式)
  ↓ model=claude-sonnet-4-5-20250929
  ↓
代理服务器 (localhost:8082)
  ↓ (转换为 OpenAI API 格式)
  ↓ model=anthropic/claude-sonnet-4.5
  ↓ (添加 HTTP-Referer, X-Title headers)
  ↓
OpenRouter API
  ↓
真实的 Claude 4.5 模型
```

### 模型映射

| Claude Code 请求 | 代理映射规则 | OpenRouter 模型 |
|-----------------|------------|----------------|
| `claude-opus-*` | → BIG_MODEL | `anthropic/claude-opus-4.5` |
| `claude-sonnet-*` | → MIDDLE_MODEL | `anthropic/claude-sonnet-4.5` |
| `claude-haiku-*` | → SMALL_MODEL | `anthropic/claude-haiku-4.5` |

---

## ✅ 验证配置

### 1. 检查代理状态
```bash
curl http://127.0.0.1:8082/health | jq
```

### 2. 查看模型配置
```bash
curl http://127.0.0.1:8082/ | jq '.config'
```

### 3. 测试连接
```bash
curl http://127.0.0.1:8082/test-connection | jq
```

---

## 💰 成本优势

使用 OpenRouter 的好处：
- 💵 比 Anthropic 官方便宜 30-50%
- 🎯 统一管理多个模型
- 🔄 灵活切换不同提供商
- 📊 统一的使用统计

---

## 🔗 相关资源

- [OpenRouter 官网](https://openrouter.ai/)
- [OpenRouter 模型列表](https://openrouter.ai/models)
- [OpenRouter API 文档](https://openrouter.ai/docs)
- [Claude Code Proxy GitHub](https://github.com/fuergaosi233/claude-code-proxy)

---

## 📝 更新日志

### v1.0.1 - OpenRouter 支持
- ✅ 添加 .env override 确保配置优先级
- ✅ 支持 OpenRouter 必需的 headers
- ✅ 完整的 Claude 4.5 系列支持
- ✅ 详细的配置文档

---

## 🤝 贡献

如果这个配置对你有帮助，欢迎：
1. Star 这个项目
2. 提交 PR 改进文档
3. 分享给其他开发者

