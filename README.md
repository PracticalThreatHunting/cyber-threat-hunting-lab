# Cyber Threat Hunting Lab

Automated threat hunting, detection engineering, DFIR, adversary emulation, and threat-intelligence lab built around PowerShell, Python, Docker, Hyper-V, Sigma, YARA-X, Velociraptor, Atomic Red Team, and related tooling.

## Safety model

The lab is designed to keep VMs isolated from the home/private LAN while permitting controlled outbound internet access. Adversary-emulation tools are **never executed automatically** by the general bootstrap process.

## Current bootstrap phase

The first implementation provides:

- host prerequisite validation
- Hyper-V enablement helper
- isolated Internal Hyper-V switch + NAT
- guest-side RFC1918 blocking policy
- local API-secret initialization
- hardened `.gitignore`
- GitHub Actions PowerShell syntax and secret-hygiene validation

See [`docs/architecture.md`](docs/architecture.md) for the design.

## First run

Clone the repository, open **PowerShell as Administrator**, and run a preflight first:

```powershell
.\bootstrap.ps1
```

The default invocation performs validation only and makes no system changes.

After reviewing the output, enable/configure the initial infrastructure explicitly:

```powershell
.\bootstrap.ps1 -Apply -ConfigureHyperV
```

If Hyper-V was newly enabled, reboot Windows before continuing. Then run:

```powershell
.\bootstrap.ps1 -Apply -ConfigureNetwork -ConfigureSecrets
```

The secret initializer prompts locally for API credentials and writes them to `secrets/.env`, which is excluded from Git.

## Planned phases

1. Hyper-V Windows 11 VM provisioning
2. Windows telemetry: Sysmon + enhanced PowerShell/event logging
3. osquery and Velociraptor
4. Sigma CLI / pySigma and YARA-X
5. Atomic Red Team installation and controlled test runners
6. Python threat-intelligence enrichment
7. CALDERA
8. OpenCTI Community Edition
9. Expanded detection-as-code CI

## Credentials

Never commit API keys, tokens, malware samples, VM disks, or investigation artifacts containing sensitive data. Use `secrets/.env` locally; `secrets/.env.example` contains variable names only.
