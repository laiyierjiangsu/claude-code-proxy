# UTF-8 encoding - PowerShell script for Claude Code with OpenRouter
# Ensure UTF-8 output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Set error action preference
$ErrorActionPreference = "Stop"

# Color definitions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-Host ""
Write-ColorOutput "================================================================" "Blue"
Write-ColorOutput "         Claude Code with OpenRouter - Windows Launcher        " "Blue"
Write-ColorOutput "================================================================" "Blue"
Write-Host ""

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Check if port 8082 is in use
Write-ColorOutput "[*] Checking port 8082..." "Cyan"
$portInUse = Get-NetTCPConnection -LocalPort 8082 -State Listen -ErrorAction SilentlyContinue

if ($portInUse) {
    Write-ColorOutput "[!] Port 8082 is already in use" "Yellow"
    Write-ColorOutput "    Proxy might be running, or port is occupied" "Yellow"
    Write-Host ""
    
    $restart = Read-Host "Stop and restart? (Y/N)"
    if ($restart -eq "Y" -or $restart -eq "y") {
        Write-ColorOutput "[*] Stopping existing processes..." "Cyan"
        
        # Get process ID using the port
        $processId = $portInUse.OwningProcess
        if ($processId) {
            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Write-ColorOutput "[+] Existing process stopped" "Green"
        }
    } else {
        Write-ColorOutput "[*] Skipping proxy startup, opening Claude Code..." "Yellow"
        Start-Sleep -Seconds 1
        Start-Process "claude"
        exit 0
    }
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-ColorOutput "[X] .env file not found!" "Red"
    Write-Host ""
    Write-ColorOutput "Please create .env file first:" "Yellow"
    Write-ColorOutput "  1. Copy .env.example to .env" "Yellow"
    Write-ColorOutput "  2. Edit with your OpenRouter API key" "Yellow"
    Write-ColorOutput "  3. Or run: .\setup_openrouter.ps1" "Yellow"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Python
Write-ColorOutput "[*] Checking Python..." "Cyan"
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-ColorOutput "[X] Python not found!" "Red"
    Write-ColorOutput "Please install Python first" "Yellow"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColorOutput "[+] Python found: $($pythonPath.Source)" "Green"

# Start proxy server
Write-ColorOutput "[*] Starting proxy server..." "Cyan"
Write-Host ""

try {
    # Start Python process in background
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "python"
    $processInfo.Arguments = "start_proxy.py"
    $processInfo.WorkingDirectory = $ScriptDir
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $false
    $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized
    
    $process = [System.Diagnostics.Process]::Start($processInfo)
    
    if ($process) {
        Write-ColorOutput "[+] Proxy process started (PID: $($process.Id))" "Green"
        
        # Save PID for later use
        $process.Id | Out-File -FilePath "$env:TEMP\claude-proxy.pid" -Encoding utf8
    } else {
        throw "Failed to start process"
    }
} catch {
    Write-ColorOutput "[X] Failed to start proxy server!" "Red"
    Write-ColorOutput "Error: $($_.Exception.Message)" "Red"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Wait for proxy to start
Write-ColorOutput "[*] Waiting for proxy to start (max 10 seconds)..." "Cyan"

$maxAttempts = 20
$attempt = 0
$proxyStarted = $false

while ($attempt -lt $maxAttempts) {
    Start-Sleep -Milliseconds 500
    $attempt++
    
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:8082/" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $proxyStarted = $true
            break
        }
    } catch {
        # Continue waiting
    }
    
    Write-Host "." -NoNewline
}

Write-Host ""
Write-Host ""

if (-not $proxyStarted) {
    Write-ColorOutput "[X] Proxy startup timeout!" "Red"
    Write-ColorOutput "Check if there are any errors in the proxy window" "Yellow"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColorOutput "[+] Proxy started successfully!" "Green"
Write-Host ""

# Get proxy configuration
Write-ColorOutput "================================================================" "Blue"
Write-ColorOutput "                    Proxy Configuration                         " "Blue"
Write-ColorOutput "================================================================" "Blue"

try {
    $configResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8082/" -TimeoutSec 3
    
    Write-ColorOutput "[*] Proxy Address:  http://127.0.0.1:8082" "Cyan"
    Write-ColorOutput "[*] Base URL:       $($configResponse.config.base_url)" "Cyan"
    Write-ColorOutput "[*] Big Model:      $($configResponse.config.big_model)" "Cyan"
    Write-ColorOutput "[*] Middle Model:   $($configResponse.config.middle_model)" "Cyan"
    Write-ColorOutput "[*] Small Model:    $($configResponse.config.small_model)" "Cyan"
} catch {
    Write-ColorOutput "[!] Could not retrieve configuration details" "Yellow"
    Write-ColorOutput "[*] Proxy Address:  http://127.0.0.1:8082" "Cyan"
}

Write-ColorOutput "================================================================" "Blue"
Write-Host ""

# Show management info
Write-ColorOutput "[i] Proxy is running in background" "Gray"
Write-ColorOutput "[i] PID saved to: $env:TEMP\claude-proxy.pid" "Gray"
Write-ColorOutput "[i] To stop proxy, run: .\stop_claude.ps1" "Gray"
Write-Host ""

# Wait a moment
Start-Sleep -Seconds 2

# Start Claude Code
Write-ColorOutput "[*] Starting Claude Code..." "Cyan"
Write-Host ""
Write-ColorOutput "================================================================" "Blue"
Write-ColorOutput " Note: After closing Claude Code, proxy will still be running  " "Yellow"
Write-ColorOutput " Run .\stop_claude.ps1 to stop the proxy server                " "Yellow"
Write-ColorOutput "================================================================" "Blue"
Write-Host ""

try {
    Start-Process "claude"
} catch {
    Write-ColorOutput "[!] Could not start Claude Code automatically" "Yellow"
    Write-ColorOutput "Please run 'claude' manually in your terminal" "Yellow"
}

Write-ColorOutput "[+] Setup complete! Enjoy your Claude Code session!" "Green"
Write-Host ""

