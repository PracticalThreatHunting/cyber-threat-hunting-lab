#requires -RunAsAdministrator
#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

if ($feature.State -eq 'Enabled') {
    Write-Host 'Hyper-V is already enabled.' -ForegroundColor Green
    return
}

Write-Host 'Enabling Hyper-V. A reboot may be required before VM provisioning.' -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart | Out-Null

$updated = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Write-Host "Hyper-V state: $($updated.State)" -ForegroundColor Cyan
if ($updated.RestartNeeded) {
    Write-Warning 'Restart Windows before continuing with lab VM deployment.'
}
