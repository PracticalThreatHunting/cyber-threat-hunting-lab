#requires -RunAsAdministrator
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required for automated host-tool installation.'
}

$packages = @(
    @{ Command = 'git';    Id = 'Git.Git';                    Name = 'Git' },
    @{ Command = 'python'; Id = 'Python.Python.3.14';          Name = 'Python 3.14' },
    @{ Command = 'code';   Id = 'Microsoft.VisualStudioCode';  Name = 'Visual Studio Code' },
    @{ Command = 'docker'; Id = 'Docker.DockerDesktop';        Name = 'Docker Desktop' }
)

foreach ($package in $packages) {
    if (Get-Command $package.Command -ErrorAction SilentlyContinue) {
        Write-Host "[PASS] $($package.Name) already available." -ForegroundColor Green
        continue
    }

    Write-Host "Installing $($package.Name)..." -ForegroundColor Cyan
    & winget install --id $package.Id --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed while installing $($package.Name) (exit $LASTEXITCODE)."
    }
}

Write-Host 'Host-tool installation phase complete. Restart Docker Desktop manually if the Docker engine is not yet reachable.' -ForegroundColor Green
