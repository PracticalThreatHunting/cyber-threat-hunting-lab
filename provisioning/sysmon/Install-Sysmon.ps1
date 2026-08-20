[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)] [string] $SysmonExe,
    [Parameter(Mandatory)] [string] $ConfigPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $SysmonExe)) { throw "Sysmon executable not found: $SysmonExe" }
if (-not (Test-Path $ConfigPath)) { throw "Sysmon configuration not found: $ConfigPath" }

$exe = (Resolve-Path $SysmonExe).Path
$config = (Resolve-Path $ConfigPath).Path

if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Install or update Sysmon configuration')) {
    $existing = Get-Service -Name Sysmon64,Sysmon -ErrorAction SilentlyContinue
    if ($existing) {
        & $exe -accepteula -c $config
    } else {
        & $exe -accepteula -i $config
    }
    if ($LASTEXITCODE -ne 0) { throw "Sysmon returned exit code $LASTEXITCODE" }
    Write-Host 'Sysmon configuration applied.' -ForegroundColor Green
}
