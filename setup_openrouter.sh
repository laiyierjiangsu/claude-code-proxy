#!/bin/bash
# OpenRouter 一键配置脚本

set -e

echo "🚀 OpenRouter 配置向导"
echo "====================="
echo ""

# 检查 .env 文件
if [ -f ".env" ]; then
    echo "⚠️  .env 文件已存在"
    read -p "是否覆盖？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 1
    fi
fi

# 提示用户输入 API Key
echo "📝 请输入你的 OpenRouter API Key"
echo "   (从 https://openrouter.ai/keys 获取)"
echo ""
read -p "API Key: " OPENROUTER_KEY

if [ -z "$OPENROUTER_KEY" ]; then
    echo "❌ API Key 不能为空"
    exit 1
fi

# 创建 .env 文件
cat > .env << EOF
# OpenRouter Configuration
OPENAI_API_KEY=$OPENROUTER_KEY
OPENAI_BASE_URL=https://openrouter.ai/api/v1

# Required headers for OpenRouter
CUSTOM_HEADER_HTTP_REFERER=
CUSTOM_HEADER_X_TITLE=

# Model configuration - Claude 4.5 系列
BIG_MODEL=anthropic/claude-opus-4.5
MIDDLE_MODEL=anthropic/claude-sonnet-4.5
SMALL_MODEL=anthropic/claude-haiku-4.5

# Server settings
HOST=127.0.0.1
PORT=8083
LOG_LEVEL=INFO
EOF

echo "✅ .env 文件已创建"
echo ""

# 检查 Python
if ! command -v python &> /dev/null; then
    echo "❌ 未找到 Python"
    exit 1
fi

echo "📦 检查依赖..."
python -c "import dotenv, fastapi, openai" 2>/dev/null || {
    echo "⚠️  缺少依赖，尝试安装..."
    pip install -q python-dotenv fastapi openai httpx uvicorn
}

echo "✅ 依赖已就绪"
echo ""

echo "🎯 配置完成！"
echo ""
echo "下一步："
echo "  1. 启动代理：python start_proxy.py"
echo "  2. 验证配置：curl http://127.0.0.1:8083/health | jq"
echo "  3. 配置 Claude Code："
echo "     export ANTHROPIC_AUTH_TOKEN=$OPENROUTER_KEY"
echo "     export ANTHROPIC_BASE_URL=http://127.0.0.1:8083"
echo ""
echo "📚 详细文档：README_OPENROUTER.md"

