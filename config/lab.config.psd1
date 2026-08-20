@{
    LabName = 'CyberThreatHuntingLab'
    SwitchName = 'CyberLab-Internal'
    NatName = 'CyberLab-NAT'
    # RFC 5737 TEST-NET-1: intentionally non-routable on the public Internet.
    LabPrefix = '192.0.2.0/24'
    GatewayAddress = '192.0.2.1'
    GatewayPrefixLength = 24

    WindowsVM = @{
        Name = 'CTH-WIN11'
        MemoryStartupBytes = 8GB
        ProcessorCount = 4
        VhdSizeBytes = 100GB
    }

    RequiredCommands = @(
        'git',
        'python',
        'docker'
    )

    ThreatIntelEnvironmentVariables = @(
        'CENSYS_API_TOKEN',
        'VIRUSTOTAL_API_KEY',
        'SHODAN_API_KEY',
        'URLSCAN_API_KEY',
        'ABUSEIPDB_API_KEY'
    )
}
