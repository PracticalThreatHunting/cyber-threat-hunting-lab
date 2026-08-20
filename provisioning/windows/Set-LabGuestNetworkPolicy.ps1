#requires -RunAsAdministrator
#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$group = 'Cyber Threat Hunting Lab Isolation'

Get-NetFirewallRule -DisplayGroup $group -ErrorAction SilentlyContinue |
    Remove-NetFirewallRule -ErrorAction SilentlyContinue

# The lab subnet is 192.0.2.0/24 (TEST-NET-1), so blocking RFC1918 space does not block
# guest-to-guest lab traffic. These rules prevent the VM from reaching typical home/private LANs.
$privateRanges = @(
    '10.0.0.0/8',
    '172.16.0.0/12',
    '192.168.0.0/16'
)

foreach ($range in $privateRanges) {
    New-NetFirewallRule `
        -DisplayName "CyberLab - Block private LAN $range" `
        -DisplayGroup $group `
        -Direction Outbound `
        -Action Block `
        -RemoteAddress $range `
        -Profile Any | Out-Null
}

Write-Host 'Guest isolation policy applied: RFC1918 destinations are blocked; public internet remains available through Hyper-V NAT.' -ForegroundColor Green
