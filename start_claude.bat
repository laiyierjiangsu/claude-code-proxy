@echo off
chcp 65001 >nul
REM UTF-8 encoding for proper character display
REM Claude Code with OpenRouter - Windows Startup Script

echo.
echo ================================================================
echo           Claude Code with OpenRouter - Windows Launcher
echo ================================================================
echo.

REM Get script directory
cd /d "%~dp0"

REM Check if port 8082 is in use
netstat -ano | findstr :8082 >nul 2>&1
if %errorlevel% == 0 (
    echo [!] Port 8082 is already in use
    echo     Proxy might be running, or port is occupied by another process
    echo.
    set /p restart="Stop and restart? (Y/N): "
    if /i "!restart!"=="Y" (
        echo [*] Stopping existing processes...
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8082') do (
            taskkill /F /PID %%a >nul 2>&1
        )
        timeout /t 2 /nobreak >nul
    ) else (
        echo [*] Skipping proxy startup, opening Claude Code directly...
        timeout /t 1 /nobreak >nul
        start "" claude
        exit /b 0
    )
)

REM Check if .env file exists
if not exist .env (
    echo [X] .env file not found!
    echo.
    echo Please create .env file first:
    echo   1. Copy .env.example to .env
    echo   2. Or run: setup_openrouter.bat
    echo.
    pause
    exit /b 1
)

REM Check Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Python not found!
    echo Please install Python first.
    echo.
    pause
    exit /b 1
)

REM Start proxy server
echo [*] Starting proxy server...
start "Claude Proxy Server" /MIN python start_proxy.py
if %errorlevel% neq 0 (
    echo [X] Failed to start proxy server!
    pause
    exit /b 1
)

REM Wait for proxy to start
echo [*] Waiting for proxy to start (max 10 seconds)...
set /a count=0
:WAIT_LOOP
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8082/ >nul 2>&1
if %errorlevel% == 0 goto PROXY_STARTED
set /a count+=1
if %count% geq 10 goto PROXY_TIMEOUT
goto WAIT_LOOP

:PROXY_TIMEOUT
echo [X] Proxy startup timeout!
echo.
echo Check the proxy window for error messages.
pause
exit /b 1

:PROXY_STARTED
echo [+] Proxy started successfully!
echo.

REM Get proxy configuration
echo ================================================================
echo                    Proxy Configuration
echo ================================================================
curl -s http://127.0.0.1:8082/ 2>nul | findstr /C:"big_model" /C:"base_url" >nul
if %errorlevel% == 0 (
    echo [*] Proxy Address: http://127.0.0.1:8082
    echo [*] Status: Running
    echo.
    echo For detailed config, open: http://127.0.0.1:8082
) else (
    echo [!] Could not retrieve configuration details
)
echo ================================================================
echo.

REM Show log information
echo [i] Proxy is running in background
echo [i] To stop proxy, run: stop_claude.bat
echo [i] Or close the "Claude Proxy Server" window
echo.

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Start Claude Code
echo [*] Starting Claude Code...
echo.
echo ================================================================
echo  Note: After closing Claude Code, proxy will still be running
echo  Run stop_claude.bat to stop the proxy server
echo ================================================================
echo.

start "" claude

exit /b 0

