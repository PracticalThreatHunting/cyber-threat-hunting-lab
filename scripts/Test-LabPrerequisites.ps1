#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [hashtable]$Config
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$results = [System.Collections.Generic.List[object]]::new()

function Add-Result([string]$Check, [bool]$Pass, [string]$Detail) {
    $results.Add([pscustomobject]@{
        Check  = $Check
        Status = if ($Pass) { 'PASS' } else { 'FAIL' }
        Detail = $Detail
    })
}

$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

Add-Result 'Windows 11' ($os.Caption -match 'Windows 11') $os.Caption
Add-Result 'Windows Pro/Enterprise' ($os.Caption -match 'Pro|Enterprise|Education') $os.Caption
Add-Result 'RAM >= 24 GB' ($computer.TotalPhysicalMemory -ge 24GB) ('{0:N1} GB' -f ($computer.TotalPhysicalMemory / 1GB))
Add-Result 'Free disk >= 250 GB' ($disk.FreeSpace -ge 250GB) ('{0:N1} GB free' -f ($disk.FreeSpace / 1GB))

# Win32_Processor.VirtualizationFirmwareEnabled may report False once the Hyper-V
# hypervisor is already active. Treat an active hypervisor as authoritative proof
# that hardware virtualization is available and enabled.
$hypervisorPresent = [bool]$computer.HypervisorPresent
$firmwareVirtualization = [bool]$cpu.VirtualizationFirmwareEnabled
$virtualizationReady = $hypervisorPresent -or $firmwareVirtualization
$virtualizationDetail = if ($hypervisorPresent) {
    'Hypervisor detected and running'
} else {
    "Firmware virtualization: $firmwareVirtualization"
}
Add-Result 'CPU virtualization ready' $virtualizationReady $virtualizationDetail

foreach ($command in $Config.RequiredCommands) {
    $resolved = Get-Command $command -ErrorAction SilentlyContinue
    Add-Result "Command: $command" ([bool]$resolved) $(if ($resolved) { $resolved.Source } else { 'Not found in PATH' })
}

$dockerVersion = $null
try { $dockerVersion = (& docker version --format '{{.Server.Version}}' 2>$null) } catch {}
Add-Result 'Docker engine reachable' ([bool]$dockerVersion) $(if ($dockerVersion) { "Server $dockerVersion" } else { 'Docker engine not reachable' })

$hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
Add-Result 'Hyper-V feature available' ([bool]$hyperV) $(if ($hyperV) { $hyperV.State } else { 'Feature unavailable' })

$results | Format-Table -AutoSize

if ($results.Status -contains 'FAIL') {
    Write-Warning 'One or more prerequisite checks failed. Review before deploying lab services.'
}
