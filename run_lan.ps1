<#
  KO'Z SHIFO — run the platform on this computer, reachable over the LAN.

  Starts the FastAPI backend bound to 0.0.0.0:8000. Because the backend also
  serves the compiled Flutter web client (build/web), the whole system is one
  URL: http://<this-computer-LAN-IP>:8000

  Open that URL in a browser on ANY device on the same network and log in as
  director (director@kozshifo.uz / Director!2026).

  Usage:
    Right-click  ->  Run with PowerShell        (normal)
    To also open the Windows Firewall port, run once as Administrator.

  Optional params:
    -Port 8000     change the listening port
    -Host 0.0.0.0  change the bind address (0.0.0.0 = all interfaces = LAN)
#>
param(
    [int]$Port = 8000,
    [string]$BindHost = '0.0.0.0'
)

$ErrorActionPreference = 'Stop'
$root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root 'backend'
$python  = Join-Path $backend '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) { $python = 'python' }   # fall back to system Python

# --- find this computer's real LAN IPv4 (skip loopback / link-local / virtual) ---
$candidates = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*' -and
        $_.InterfaceAlias -notmatch 'Loopback|vEthernet|Docker|WSL|Hyper-V|VirtualBox|VMware'
    } |
    Select-Object -ExpandProperty IPAddress
$lanIp = if ($candidates) { @($candidates)[0] } else { '127.0.0.1' }

# --- open the firewall port (needs admin; harmless if it fails) ---
$ruleName = "KOZ SHIFO LAN $Port"
if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
    try {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
            -Protocol TCP -LocalPort $Port -Profile Any -ErrorAction Stop | Out-Null
        Write-Host "[ok] Firewall opened for TCP $Port" -ForegroundColor Green
    } catch {
        Write-Warning "Could not open the firewall (run this script once as Administrator)."
        Write-Warning "Other devices on the LAN may be blocked until TCP $Port is allowed."
    }
}

Write-Host ''
Write-Host '==================================================================' -ForegroundColor Cyan
Write-Host '  KO''Z SHIFO is starting...' -ForegroundColor Cyan
Write-Host ''
Write-Host "  On THIS computer:   http://localhost:$Port"
Write-Host "  On the network:     http://$lanIp`:$Port      <-- open this on other devices" -ForegroundColor Yellow
Write-Host ''
Write-Host '  Director login:     director@kozshifo.uz  /  Director!2026'
Write-Host '  TV board:           http://'"$lanIp"":$Port/tv/<branch-id>"
Write-Host '  API docs:           http://'"$lanIp"":$Port/docs"
Write-Host ''
Write-Host '  Keep this window open. Press Ctrl+C to stop the server.' -ForegroundColor DarkGray
Write-Host '==================================================================' -ForegroundColor Cyan
Write-Host ''

Set-Location $backend
& $python -m uvicorn app.main:app --host $BindHost --port $Port
