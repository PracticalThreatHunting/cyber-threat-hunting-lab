# Windows Lab VM Provisioning

This phase creates the first isolated Windows 11 detection endpoint.

## Target defaults

- VM name: `TH-LAB-WIN11`
- Generation: 2
- vCPU: 4
- Startup RAM: 10 GB
- Dynamic RAM: 4–14 GB
- VHDX: 120 GB dynamic
- Network: `TH-LAB-NAT`
- Secure Boot: Microsoft Windows template
- Automatic checkpoints: disabled

These defaults are sized for the 32 GB analyst laptop used to build the lab. They can be overridden at invocation time.

## Prerequisites

1. Run bootstrap v1 and complete any required reboot.
2. Confirm the `TH-LAB-NAT` Hyper-V switch exists.
3. Obtain a legitimate Windows 11 installation ISO and store it locally.
4. Open an elevated PowerShell session.

## Create the VM

```powershell
.\infrastructure\hyperv\New-LabWindowsVM.ps1 -IsoPath 'C:\ISO\Windows11.iso'
```

The script refuses to overwrite an existing VM with the same name.

## Install Windows

Start `TH-LAB-WIN11` and complete the Windows installation from the attached ISO. Fully unattended Windows setup is intentionally deferred until an installation image and desired local-account policy are selected and tested.

## Guest telemetry

After Windows installation, copy or clone this repository inside the VM and run from elevated PowerShell:

```powershell
.\provisioning\windows\Enable-Telemetry.ps1
```

This enables PowerShell Script Block Logging, Module Logging, transcription, process-creation auditing, command-line capture, and the PowerShell Operational event channel.

## Sysmon

Sysmon installation is intentionally local-input driven: the lab does not silently fetch or execute a mutable remote binary. Obtain Sysmon and the selected configuration, then run:

```powershell
.\provisioning\sysmon\Install-Sysmon.ps1 `
  -SysmonExe 'C:\Tools\Sysmon64.exe' `
  -ConfigPath 'C:\Tools\sysmonconfig.xml'
```

A vetted Sysmon configuration will be added in a later phase.

## Safety model

Adversary-emulation tools are not started by provisioning. The Windows endpoint is built as an observation target first; Atomic Red Team and CALDERA are added only after telemetry and recovery checkpoints are validated.
