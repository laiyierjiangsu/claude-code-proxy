# UTF-8 encoding - PowerShell script to stop Claude Code Proxy
# Ensure UTF-8 output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
Write-ColorOutput "              Stop Claude Code Proxy Server                     " "Blue"
Write-ColorOutput "================================================================" "Blue"
Write-Host ""

$processFound = $false

# Method 1: Check PID file
$pidFile = "$env:TEMP\claude-proxy.pid"
if (Test-Path $pidFile) {
    Write-ColorOutput "[*] Found PID file: $pidFile" "Cyan"
    
    try {
        $pid = Get-Content $pidFile -ErrorAction Stop
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        
        if ($process) {
            Write-ColorOutput "[*] Found proxy process (PID: $pid)" "Cyan"
            Stop-Process -Id $pid -Force
            $processFound = $true
            Write-ColorOutput "[+] Process $pid stopped" "Green"
        } else {
            Write-ColorOutput "[i] Process $pid no longer running" "Gray"
        }
        
        # Remove PID file
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
    } catch {
        Write-ColorOutput "[!] Could not read PID file" "Yellow"
    }
}

# Method 2: Check port 8082
Write-Host ""
Write-ColorOutput "[*] Checking port 8082..." "Cyan"

$connections = Get-NetTCPConnection -LocalPort 8082 -State Listen -ErrorAction SilentlyContinue

if ($connections) {
    foreach ($conn in $connections) {
        $pid = $conn.OwningProcess
        Write-ColorOutput "[*] Found process on port 8082 (PID: $pid)" "Cyan"
        
        try {
            $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
            if ($process) {
                Write-ColorOutput "[*] Process name: $($process.ProcessName)" "Gray"
                Stop-Process -Id $pid -Force
                $processFound = $true
                Write-ColorOutput "[+] Process $pid stopped" "Green"
            }
        } catch {
            Write-ColorOutput "[!] Could not stop process $pid" "Yellow"
        }
    }
    
    Start-Sleep -Seconds 1
    
    # Verify port is released
    $stillInUse = Get-NetTCPConnection -LocalPort 8082 -State Listen -ErrorAction SilentlyContinue
    if (-not $stillInUse) {
        Write-ColorOutput "[+] Port 8082 released successfully" "Green"
    } else {
        Write-ColorOutput "[!] Port 8082 still in use" "Yellow"
        Write-Host ""
        Write-ColorOutput "Active connections on port 8082:" "Yellow"
        Get-NetTCPConnection -LocalPort 8082 | Format-Table -AutoSize
    }
} else {
    Write-ColorOutput "[i] No process found on port 8082" "Gray"
}

# Method 3: Find Python processes running start_proxy.py
Write-Host ""
Write-ColorOutput "[*] Looking for Python proxy processes..." "Cyan"

$pythonProcesses = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*proxy*" -or 
    $_.CommandLine -like "*start_proxy*"
}

if ($pythonProcesses) {
    foreach ($proc in $pythonProcesses) {
        Write-ColorOutput "[*] Found Python process (PID: $($proc.Id))" "Cyan"
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        $processFound = $true
        Write-ColorOutput "[+] Process $($proc.Id) stopped" "Green"
    }
}

# Summary
Write-Host ""
Write-ColorOutput "================================================================" "Blue"
Write-ColorOutput "                     Operation Complete                         " "Blue"
Write-ColorOutput "================================================================" "Blue"
Write-Host ""

if ($processFound) {
    Write-ColorOutput "[+] Proxy server stopped successfully" "Green"
} else {
    Write-ColorOutput "[i] No running proxy server found" "Gray"
}

Write-Host ""
Read-Host "Press Enter to exit"

