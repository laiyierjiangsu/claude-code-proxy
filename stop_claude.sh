#!/bin/bash
# 停止 Claude Code 代理服务器

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛑 停止 Claude Code 代理服务器${NC}"
echo ""

# 检查 PID 文件
if [ -f /tmp/claude-proxy.pid ]; then
    PID=$(cat /tmp/claude-proxy.pid)
    if kill -0 $PID 2>/dev/null; then
        echo -e "${BLUE}📋 找到代理进程 (PID: $PID)${NC}"
        kill $PID
        sleep 1
        
        # 确认是否停止
        if kill -0 $PID 2>/dev/null; then
            echo -e "${YELLOW}⚠️  进程未响应，强制停止...${NC}"
            kill -9 $PID 2>/dev/null
        fi
        
        echo -e "${GREEN}✅ 代理已停止${NC}"
        rm -f /tmp/claude-proxy.pid
    else
        echo -e "${YELLOW}⚠️  PID 文件存在但进程未运行${NC}"
        rm -f /tmp/claude-proxy.pid
    fi
else
    echo -e "${YELLOW}📋 未找到 PID 文件，尝试按名称查找进程...${NC}"
fi

# 尝试按进程名停止
if pkill -f "python.*start_proxy.py" 2>/dev/null; then
    echo -e "${GREEN}✅ 已停止所有 start_proxy.py 进程${NC}"
else
    echo -e "${BLUE}ℹ️  没有发现运行中的代理进程${NC}"
fi

# 检查端口是否释放
echo ""
if lsof -i :8082 >/dev/null 2>&1; then
    echo -e "${RED}⚠️  端口 8082 仍被占用${NC}"
    echo -e "${YELLOW}占用进程：${NC}"
    lsof -i :8082
else
    echo -e "${GREEN}✅ 端口 8082 已释放${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 操作完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

