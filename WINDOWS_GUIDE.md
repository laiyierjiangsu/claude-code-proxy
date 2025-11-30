# 🪟 Windows 使用指南

本指南专门针对 Windows 用户，帮助你在 Windows 平台上使用 claude-code-proxy。

---

## 📋 系统要求

- ✅ Windows 10/11
- ✅ Python 3.8 或更高版本
- ✅ Claude Code CLI 已安装
- ✅ OpenRouter API Key

---

## 🚀 快速开始

### 方法 1: PowerShell 脚本（推荐）

**特点**：功能最强大，输出带颜色，体验最好

```powershell
# 启动
.\start_claude.ps1

# 停止
.\stop_claude.ps1
```

**首次运行可能需要设置执行策略：**

```powershell
# 查看当前策略
Get-ExecutionPolicy

# 如果是 Restricted，设置为 RemoteSigned（推荐）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或者临时绕过（仅本次）
powershell -ExecutionPolicy Bypass -File .\start_claude.ps1
```

---

### 方法 2: 批处理脚本

**特点**：双击即可运行，无需设置权限

```cmd
# 启动
start_claude.bat

# 停止
stop_claude.bat
```

直接双击 `.bat` 文件即可！

---

### 方法 3: 手动启动

**适合喜欢手动控制的用户**

```cmd
# 1. 启动代理（新开一个 CMD 窗口）
python start_proxy.py

# 2. 启动 Claude Code（另一个 CMD 窗口）
claude
```

---

## ⚙️ 配置 .env 文件

### 自动配置（推荐）

如果你有 **Git Bash** 或 **WSL**：

```bash
./setup_openrouter.sh
```

### 手动配置

创建 `.env` 文件（在项目根目录）：

```bash
# OpenRouter Configuration
OPENAI_API_KEY=sk-or-v1-你的OpenRouter密钥
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
PORT=8082
LOG_LEVEL=INFO
```

**注意**：
- 使用 **UTF-8 编码**保存 `.env` 文件
- 在 Notepad++ 中：编码 → 以 UTF-8 无 BOM 格式编码
- 在 VS Code 中：右下角选择 UTF-8

---

## 🔧 环境变量配置

### Windows 用户环境变量

**方式 1：通过图形界面**

1. 右键"此电脑" → 属性 → 高级系统设置
2. 环境变量 → 用户变量 → 新建

添加以下变量：

```
变量名：ANTHROPIC_AUTH_TOKEN
变量值：sk-or-v1-你的OpenRouter密钥

变量名：ANTHROPIC_BASE_URL
变量值：http://127.0.0.1:8082
```

**方式 2：通过 PowerShell**

```powershell
# 设置用户环境变量
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'sk-or-v1-你的密钥', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'http://127.0.0.1:8082', 'User')

# 验证
[System.Environment]::GetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'User')
```

**方式 3：通过 CMD**

```cmd
setx ANTHROPIC_AUTH_TOKEN "sk-or-v1-你的密钥"
setx ANTHROPIC_BASE_URL "http://127.0.0.1:8082"
```

**⚠️ 重要**：设置环境变量后，需要**重启终端**才能生效！

---

## 📊 脚本功能对比

| 功能 | PowerShell (.ps1) | 批处理 (.bat) | 手动 |
|-----|------------------|--------------|------|
| 双击运行 | ✅ | ✅ | ❌ |
| 彩色输出 | ✅ | ❌ | ❌ |
| 端口检测 | ✅ | ✅ | ❌ |
| 配置验证 | ✅ | ✅ | ❌ |
| 智能重启 | ✅ | ✅ | ❌ |
| 显示配置 | ✅ | ⚠️ | ❌ |
| PID 管理 | ✅ | ⚠️ | ❌ |

---

## 🐛 故障排查

### 问题 1: 脚本无法运行

**症状**：双击 `.ps1` 文件没反应

**解决方案**：

```powershell
# 右键 .ps1 文件 → 使用 PowerShell 运行
# 或在 PowerShell 中执行
.\start_claude.ps1

# 如果提示权限错误，设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### 问题 2: 中文乱码

**症状**：脚本输出显示乱码

**解决方案**：

```cmd
# CMD 中设置 UTF-8
chcp 65001

# PowerShell 中已自动设置
```

**检查文件编码**：
- 确保 `.env` 文件是 **UTF-8** 编码
- 确保 `.bat` 和 `.ps1` 文件是 **UTF-8** 编码

---

### 问题 3: 端口被占用

**症状**：提示端口 8082 已被占用

**解决方案**：

**方式 1：使用停止脚本**
```powershell
.\stop_claude.ps1
```

**方式 2：手动查找并停止**
```cmd
# 查找占用端口的进程
netstat -ano | findstr :8082

# 停止进程（替换 <PID> 为实际进程 ID）
taskkill /F /PID <PID>
```

**方式 3：使用 PowerShell**
```powershell
# 查找并停止
Get-NetTCPConnection -LocalPort 8082 | ForEach-Object {
    Stop-Process -Id $_.OwningProcess -Force
}
```

---

### 问题 4: Python 找不到

**症状**：提示 "Python not found"

**解决方案**：

1. 安装 Python：https://www.python.org/downloads/
2. 安装时勾选 "Add Python to PATH"
3. 验证安装：
   ```cmd
   python --version
   ```

---

### 问题 5: Claude Code 无法连接代理

**检查清单**：

1. **代理是否运行**：
   ```cmd
   curl http://127.0.0.1:8082/health
   ```

2. **环境变量是否设置**：
   ```powershell
   [System.Environment]::GetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'User')
   [System.Environment]::GetEnvironmentVariable('ANTHROPIC_BASE_URL', 'User')
   ```

3. **重启终端**：环境变量修改后需要重启

4. **检查 .env 配置**：
   ```cmd
   type .env
   ```

---

## 💡 使用技巧

### 创建桌面快捷方式

**对于批处理脚本**：
1. 右键 `start_claude.bat`
2. 发送到 → 桌面快捷方式
3. 双击快捷方式即可启动

**对于 PowerShell 脚本**：
1. 创建快捷方式
2. 目标设置为：
   ```
   powershell.exe -ExecutionPolicy Bypass -File "C:\完整路径\start_claude.ps1"
   ```

---

### 查看代理日志

代理运行在后台，如果需要查看日志：

**方式 1：任务管理器**
1. 打开任务管理器（Ctrl+Shift+Esc）
2. 找到 Python 进程
3. 右键 → 打开文件位置

**方式 2：修改启动脚本**

在 `.bat` 文件中，将：
```batch
start "Claude Proxy Server" /MIN python start_proxy.py
```

改为（不最小化）：
```batch
start "Claude Proxy Server" python start_proxy.py
```

---

### 自动启动（开机启动）

**方式 1：启动文件夹**
1. Win+R → 输入 `shell:startup`
2. 将 `start_claude.bat` 的快捷方式复制到此文件夹

**方式 2：任务计划程序**
1. Win+R → 输入 `taskschd.msc`
2. 创建基本任务
3. 触发器：登录时
4. 操作：启动程序 → 选择 `start_claude.bat`

---

## 📚 相关文档

- **完整配置指南**：`OPENROUTER_GUIDE.md`
- **快速开始**：`OPENROUTER_QUICKSTART.md`
- **安全最佳实践**：`SECURITY.md`
- **使用指南**（Linux/Mac）：`USAGE.md`

---

## 🆘 需要帮助？

### 常用命令速查

```powershell
# 启动（PowerShell）
.\start_claude.ps1

# 停止（PowerShell）
.\stop_claude.ps1

# 查看环境变量
[System.Environment]::GetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'User')

# 测试代理
Invoke-WebRequest -Uri http://127.0.0.1:8082/health

# 查看端口占用
Get-NetTCPConnection -LocalPort 8082
```

```cmd
REM 启动（CMD/批处理）
start_claude.bat

REM 停止（CMD/批处理）
stop_claude.bat

REM 查看环境变量
echo %ANTHROPIC_AUTH_TOKEN%

REM 测试代理
curl http://127.0.0.1:8082/health

REM 查看端口占用
netstat -ano | findstr :8082
```

---

## ✅ 快速测试

运行以下命令测试是否正常工作：

```powershell
# 1. 启动代理
.\start_claude.ps1

# 2. 在新的 PowerShell 窗口测试
Invoke-RestMethod -Uri http://127.0.0.1:8082/ | ConvertTo-Json

# 3. 看到配置信息说明成功！
```

---

**🎉 享受你的 Windows 版 Claude Code with OpenRouter！**

