[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)] [string] $IsoPath,
    [string] $VmName = 'CTH-WIN11',
    [string] $SwitchName = 'CyberLab-Internal',
    [string] $VmRoot = "$env:ProgramData\PracticalThreatHunting\VMs",
    [int] $MemoryGB = 8,
    [int] $Vcpu = 4,
    [int] $DiskGB = 100
)

$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = [Security.Principal.WindowsPrincipal]::new($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from an elevated PowerShell session.'
    }
}

Assert-Administrator

if (-not (Test-Path $IsoPath)) { throw "ISO not found: $IsoPath" }
if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
    throw "Hyper-V switch '$SwitchName' does not exist. Run the network bootstrap first."
}
if (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
    throw "VM '$VmName' already exists. Refusing to overwrite it."
}

$vmDir = Join-Path $VmRoot $VmName
$vhdPath = Join-Path $vmDir "$VmName.vhdx"
New-Item -ItemType Directory -Path $vmDir -Force | Out-Null

if ($PSCmdlet.ShouldProcess($VmName, 'Create isolated Windows 11 Hyper-V lab VM')) {
    New-VHD -Path $vhdPath -SizeBytes (${DiskGB}GB) -Dynamic | Out-Null
    $vm = New-VM -Name $VmName -Generation 2 -MemoryStartupBytes (${MemoryGB}GB) -VHDPath $vhdPath -SwitchName $SwitchName -Path $vmDir
    Set-VMProcessor -VMName $VmName -Count $Vcpu
    Set-VMMemory -VMName $VmName -DynamicMemoryEnabled $true -MinimumBytes 4GB -StartupBytes (${MemoryGB}GB) -MaximumBytes 12GB
    Set-VM -VMName $VmName -AutomaticCheckpointsEnabled $false -CheckpointType Production
    Set-VMFirmware -VMName $VmName -EnableSecureBoot On -SecureBootTemplate 'MicrosoftWindows'

    Add-VMDvdDrive -VMName $VmName -Path $IsoPath | Out-Null
    $dvd = Get-VMDvdDrive -VMName $VmName
    $disk = Get-VMHardDiskDrive -VMName $VmName
    Set-VMFirmware -VMName $VmName -BootOrder $dvd, $disk

    Write-Host "Created $VmName" -ForegroundColor Green
    Write-Host "ISO: $IsoPath"
    Write-Host "Switch: $SwitchName"
    Write-Host "RAM: $MemoryGB GB | vCPU: $Vcpu | Disk: $DiskGB GB"
    Write-Host 'Start the VM to install Windows. Automated guest provisioning is handled separately.'
}
