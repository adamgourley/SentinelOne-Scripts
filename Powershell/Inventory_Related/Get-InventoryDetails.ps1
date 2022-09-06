# This script is used to gather system details, for inventorying purposes.
# Version 1.0
# Author(s): Adam Gourley
# RSO Type: Artifact Collection

<#

.SYNOPSIS
Gets a variety of information from the computer and returns it as a PS Object, or exports it to a CSV.

.PARAMETER Path
Takes a path to use for CSV export.

.EXAMPLE
Export the information to a CSV file.
.\Get-InventoryDetails.ps1 -Path .\inventory.csv

.EXAMPLE
Only return the information to the shell.
.\Get-InventoryDetails.ps1

#>

param(
    [Parameter(Mandatory = $false,
        ParameterSetName = "Path",
        HelpMessage = "Enter the CSV output file path",
        Position = 0)]
    [String]$Path
)

function Get-InventoryDetails {
    [PSCustomObject]@{
        "SystemDate" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "ComputerName" = hostname.exe
        "Manufacturer" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Manufacturer
        "Domain" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Domain
        "Model" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Model
        "SerialNumber" = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber | Select-String -Pattern "1"
        "InstalledRAM" = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
        "ProcessorName" = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*" | Select-Object -ExpandProperty Name
        "ProcessorCount" = Get-CimInstance -ClassName Win32_Processor |  Select-Object -ExpandProperty NumberOfCores
        "HostOS" = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption
        "OSBuild" = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')
        "AvailableSpace" = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$env:systemdrive'" | ForEach-Object { [math]::Round($_.Size / 1GB,2) }
        "BIOSVersion" = Get-CimInstance -ClassName Win32_Bios | Select-Object -ExpandProperty SMBIOSBIOSVersion
        "IPAddress" = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $null -ne $_.DefaultIPGateway }).IPAddress | Select-Object -First 1
        "MACAddress" = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $null -ne $_.DefaultIPGateway } | Select-Object -ExpandProperty MACAddress
        "LoggedOnUser" = Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName | Select-Object -ExpandProperty UserName
    }
}

if ($Path) {
    <# If path is supplied, export to CSV. #>
    Get-InventoryDetails | Select-Object * | Export-CSV -Path $Path
} else {
    <# Just return the output to the console #>
    return Get-InventoryDetails
}