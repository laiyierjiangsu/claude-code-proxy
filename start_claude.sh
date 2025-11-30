#!/bin/bash
# Claude Code 一键启动脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           🚀 Claude Code with OpenRouter 一键启动               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 检查是否已有代理在运行
if lsof -i :8082 >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  检测到端口 8082 已被占用${NC}"
    echo -e "${YELLOW}   可能代理已经在运行，或被其他程序占用${NC}"
    echo ""
    read -p "是否停止现有进程并重启？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🛑 停止现有进程...${NC}"
        pkill -f "python.*start_proxy.py" || true
        sleep 2
    else
        echo -e "${YELLOW}⏭️  跳过代理启动，直接打开 Claude Code${NC}"
        sleep 1
        exec claude
        exit 0
    fi
fi

# 检查 .env 文件
if [ ! -f .env ]; then
    echo -e "${RED}❌ 未找到 .env 文件${NC}"
    echo -e "${YELLOW}💡 提示：运行 ./setup_openrouter.sh 进行配置${NC}"
    exit 1
fi

# 检查 Python
if ! command -v python &> /dev/null; then
    echo -e "${RED}❌ 未找到 Python${NC}"
    exit 1
fi

# 启动代理服务器
echo -e "${BLUE}🚀 启动代理服务器...${NC}"
python start_proxy.py > /tmp/claude-proxy.log 2>&1 &
PROXY_PID=$!

# 保存 PID 到文件
echo $PROXY_PID > /tmp/claude-proxy.pid

# 等待代理启动
echo -e "${BLUE}⏳ 等待代理启动（最多 10 秒）...${NC}"
for i in {1..20}; do
    if curl -s http://127.0.0.1:8082/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 代理已启动！${NC}"
        break
    fi
    sleep 0.5
    
    # 检查进程是否还在运行
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        echo -e "${RED}❌ 代理启动失败！${NC}"
        echo ""
        echo -e "${YELLOW}📋 错误日志：${NC}"
        tail -20 /tmp/claude-proxy.log
        exit 1
    fi
    
    if [ $i -eq 20 ]; then
        echo -e "${RED}❌ 代理启动超时！${NC}"
        echo ""
        echo -e "${YELLOW}📋 日志：${NC}"
        tail -20 /tmp/claude-proxy.log
        kill $PROXY_PID 2>/dev/null || true
        exit 1
    fi
done

# 获取代理配置
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 代理配置信息${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CONFIG=$(curl -s http://127.0.0.1:8082/ 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "$CONFIG" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    config = data.get('config', {})
    print(f\"📍 代理地址: http://127.0.0.1:8082\")
    print(f\"🌐 Base URL:  {config.get('base_url', 'N/A')}\")
    print(f\"🤖 大模型:    {config.get('big_model', 'N/A')}\")
    print(f\"🤖 中模型:    {config.get('middle_model', 'N/A')}\")
    print(f\"🤖 小模型:    {config.get('small_model', 'N/A')}\")
except:
    print('⚠️  无法解析配置')
" 2>/dev/null || echo "⚠️  无法获取配置详情"
fi

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 提示日志位置
echo -e "${BLUE}📝 代理日志: /tmp/claude-proxy.log${NC}"
echo -e "${BLUE}📝 查看日志: tail -f /tmp/claude-proxy.log${NC}"
echo -e "${BLUE}🛑 停止代理: kill \$(cat /tmp/claude-proxy.pid)${NC}"
echo ""

# 等待 1 秒让用户看到信息
sleep 1

# 启动 Claude Code
echo -e "${GREEN}🎯 正在打开 Claude Code...${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}💡 提示：Claude Code 关闭后，代理仍在后台运行${NC}"
echo -e "${YELLOW}   如需停止代理，请运行：${NC}"
echo -e "${YELLOW}   kill \$(cat /tmp/claude-proxy.pid)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 启动 Claude Code
exec claude

