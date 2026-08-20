#requires -RunAsAdministrator
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command Get-VMSwitch -ErrorAction SilentlyContinue)) {
    throw 'Hyper-V PowerShell module is not available. Enable Hyper-V and reboot first.'
}

$switch = Get-VMSwitch -Name $Config.SwitchName -ErrorAction SilentlyContinue
if (-not $switch) {
    New-VMSwitch -Name $Config.SwitchName -SwitchType Internal | Out-Null
    Write-Host "Created internal vSwitch: $($Config.SwitchName)" -ForegroundColor Green
} else {
    Write-Host "vSwitch already exists: $($Config.SwitchName)" -ForegroundColor Green
}

$adapterAlias = "vEthernet ($($Config.SwitchName))"
$adapter = Get-NetAdapter -Name $adapterAlias -ErrorAction Stop

$existingAddress = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $Config.GatewayAddress }

if (-not $existingAddress) {
    Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.PrefixOrigin -ne 'WellKnown' } |
        Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

    New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress $Config.GatewayAddress -PrefixLength $Config.GatewayPrefixLength | Out-Null
    Write-Host "Assigned gateway $($Config.GatewayAddress)/$($Config.GatewayPrefixLength)" -ForegroundColor Green
}

$nat = Get-NetNat -Name $Config.NatName -ErrorAction SilentlyContinue
if (-not $nat) {
    New-NetNat -Name $Config.NatName -InternalIPInterfaceAddressPrefix $Config.LabPrefix | Out-Null
    Write-Host "Created NAT: $($Config.NatName) -> $($Config.LabPrefix)" -ForegroundColor Green
} elseif ($nat.InternalIPInterfaceAddressPrefix -ne $Config.LabPrefix) {
    throw "NAT '$($Config.NatName)' exists with prefix $($nat.InternalIPInterfaceAddressPrefix), expected $($Config.LabPrefix)."
}

Write-Host 'Lab network created. Guest-side policy will block RFC1918 destinations so lab VMs cannot reach the home LAN.' -ForegroundColor Cyan
