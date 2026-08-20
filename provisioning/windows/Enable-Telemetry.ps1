[CmdletBinding(SupportsShouldProcess=$true)]
param()

$ErrorActionPreference = 'Stop'

function Assert-Administrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = [Security.Principal.WindowsPrincipal]::new($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from an elevated PowerShell session.'
    }
}

Assert-Administrator

if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Enable PowerShell and process-creation telemetry')) {
    New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name EnableScriptBlockLogging -PropertyType DWord -Value 1 -Force | Out-Null

    New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging' -Name EnableModuleLogging -PropertyType DWord -Value 1 -Force | Out-Null
    New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames' -Name '*' -PropertyType String -Value '*' -Force | Out-Null

    New-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription' -Name EnableTranscripting -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription' -Name IncludeInvocationHeader -PropertyType DWord -Value 1 -Force | Out-Null

    auditpol /set /subcategory:'Process Creation' /success:enable | Out-Null
    New-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Name ProcessCreationIncludeCmdLine_Enabled -PropertyType DWord -Value 1 -Force | Out-Null

    wevtutil sl Microsoft-Windows-PowerShell/Operational /e:true | Out-Null

    Write-Host 'PowerShell and process-creation telemetry enabled.' -ForegroundColor Green
}
