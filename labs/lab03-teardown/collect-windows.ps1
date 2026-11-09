# Run in Windows PowerShell from the lab03-teardown folder:
# powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\collect-windows.ps1
$folder = Split-Path -Parent $MyInvocation.MyCommand.Path
$evidence = Join-Path $folder 'evidence'
New-Item -ItemType Directory -Path $evidence -Force | Out-Null
$output = Join-Path $evidence 'windows-specs.txt'
"Lab 3 - Windows PowerShell raw command output (collected: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))" | Out-File -FilePath $output -Encoding utf8
$commands = @(
    'Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed',
    'Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator, Capacity, Speed, ConfiguredClockSpeed, SMBIOSMemoryType, FormFactor',
    'Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory',
    'Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType, Size',
    'Get-Volume -DriveLetter C',
    '$env:PROCESSOR_ARCHITECTURE'
)
foreach ($command in $commands) {
    "`r`nPS> $command" | Out-File -FilePath $output -Append -Encoding utf8
    try {
        Invoke-Expression $command 2>&1 | Out-String -Width 230 | Out-File -FilePath $output -Append -Encoding utf8
    } catch {
        "ERROR: $($_.Exception.Message)" | Out-File -FilePath $output -Append -Encoding utf8
    }
}
Write-Host "Created $output"
