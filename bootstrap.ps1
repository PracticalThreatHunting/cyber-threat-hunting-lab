#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Apply,
    [switch]$InstallHostTools,
    [switch]$ConfigureHyperV,
    [switch]$ConfigureNetwork,
    [switch]$ConfigureSecrets
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Config = Import-PowerShellDataFile (Join-Path $Root 'config\lab.config.psd1')

function Write-Stage([string]$Message) {
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run bootstrap.ps1 from an elevated PowerShell session.'
    }
}

Assert-Administrator

Write-Stage 'Preflight'
& (Join-Path $Root 'scripts\Test-LabPrerequisites.ps1') -Config $Config

if (-not $Apply) {
    Write-Host '`nDry-run/preflight complete. No system changes were made.' -ForegroundColor Yellow
    Write-Host 'Re-run with -Apply and the components you want, for example:'
    Write-Host '  .\bootstrap.ps1 -Apply -ConfigureHyperV -ConfigureNetwork -ConfigureSecrets'
    exit 0
}

if ($InstallHostTools) {
    Write-Stage 'Host tooling'
    & (Join-Path $Root 'scripts\Install-HostTools.ps1') -Config $Config
}

if ($ConfigureHyperV) {
    Write-Stage 'Hyper-V'
    & (Join-Path $Root 'infrastructure\hyperv\Enable-HyperV.ps1')
}

if ($ConfigureNetwork) {
    Write-Stage 'Isolated lab network'
    & (Join-Path $Root 'infrastructure\hyperv\New-LabNetwork.ps1') -Config $Config
}

if ($ConfigureSecrets) {
    Write-Stage 'Local threat-intelligence secrets'
    & (Join-Path $Root 'scripts\Initialize-Secrets.ps1') -Config $Config
}

Write-Stage 'Validation'
& (Join-Path $Root 'scripts\Test-LabPrerequisites.ps1') -Config $Config

Write-Host '`nBootstrap phase completed. Adversary-emulation tools are never executed automatically.' -ForegroundColor Green
