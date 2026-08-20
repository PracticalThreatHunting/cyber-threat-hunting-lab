# Lab Architecture

## Goals

Build a reproducible Windows-focused threat hunting and detection engineering lab that is isolated from the home LAN while retaining controlled outbound internet access for updates and threat-intelligence APIs.

## Host

- Windows 11 Pro
- Hyper-V
- Docker Desktop
- Git
- Python
- VS Code

## Network

The initial Hyper-V network uses an **Internal** vSwitch and Windows NAT.

- Lab prefix: `192.0.2.0/24`
- Host/gateway: `192.0.2.1`
- Lab VMs: static addresses from the same prefix
- Guest firewall policy blocks RFC1918 destinations (`10/8`, `172.16/12`, `192.168/16`) to prevent access to typical home/private LANs.
- Public internet remains available through NAT.

`192.0.2.0/24` is TEST-NET-1, reserved for documentation and not publicly routed.

## Initial Windows VM

Planned baseline:

- 4 vCPU
- 8 GB startup RAM
- 100 GB VHDX
- Windows 11
- Sysmon
- PowerShell logging
- osquery
- Velociraptor client
- Atomic Red Team

Adversary-emulation tooling is installed separately and is never executed by the general bootstrap process.

## Detection Toolchain

Planned host-side tooling:

- Sigma CLI / pySigma
- YARA-X
- Python virtual environments
- Detection validation/tests
- GitHub Actions CI

## Threat Intelligence

Local tooling will support API enrichment using credentials stored only in `secrets/.env`:

- Censys
- VirusTotal
- Shodan
- urlscan.io
- AbuseIPDB

The secrets file is excluded from Git. Public examples contain variable names only.

## Later Phases

- Velociraptor server
- CALDERA
- OpenCTI Community Edition
- Python IOC enrichment service
- Additional detection backends: Splunk SPL, Microsoft KQL, LogScale
- Automated validation of Sigma and YARA-X rules
