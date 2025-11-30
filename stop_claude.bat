@echo off
chcp 65001 >nul
REM UTF-8 encoding for proper character display
REM Stop Claude Code Proxy Server

echo.
echo ================================================================
echo              Stop Claude Code Proxy Server
echo ================================================================
echo.

REM Find and stop processes using port 8082
echo [*] Looking for proxy server on port 8082...

netstat -ano | findstr :8082 >nul 2>&1
if %errorlevel% neq 0 (
    echo [i] No process found on port 8082
    echo [i] Proxy may not be running
    goto CHECK_PYTHON
)

echo [*] Found process on port 8082, stopping...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8082') do (
    echo [*] Stopping PID: %%a
    taskkill /F /PID %%a >nul 2>&1
    if !errorlevel! == 0 (
        echo [+] Process %%a stopped
    )
)

timeout /t 1 /nobreak >nul

REM Verify port is released
netstat -ano | findstr :8082 >nul 2>&1
if %errorlevel% neq 0 (
    echo [+] Port 8082 released successfully
) else (
    echo [!] Port 8082 still in use
    echo.
    echo Active connections on port 8082:
    netstat -ano | findstr :8082
)

:CHECK_PYTHON
echo.
echo [*] Looking for Python proxy processes...

REM Try to find and stop Python processes with start_proxy.py
tasklist /FI "IMAGENAME eq python.exe" /V 2>nul | findstr /C:"start_proxy" >nul 2>&1
if %errorlevel% == 0 (
    echo [*] Found Python proxy processes, stopping...
    taskkill /F /IM python.exe /FI "WINDOWTITLE eq *Claude Proxy*" >nul 2>&1
    taskkill /F /IM python.exe /FI "WINDOWTITLE eq *start_proxy*" >nul 2>&1
    echo [+] Python proxy processes stopped
) else (
    echo [i] No Python proxy processes found
)

echo.
echo ================================================================
echo                     Operation Complete
echo ================================================================
echo.
echo [+] Proxy server should be stopped now
echo.

pause

