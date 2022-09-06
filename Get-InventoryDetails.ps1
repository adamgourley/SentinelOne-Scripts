# This script is used to gather laptop details, for inventorying purposes.
# Version 1.0
# Author(s): Adam Gourley
# RSO Type: Artifact Collection

param(
    [Parameter(Mandatory = $true,
        ParameterSetName = "Path",
        HelpMessage = "Enter the CSV output file path",
        Position = 0)]
    [String]$Path
)

function InventoryDetails {
    [PSCustomObject]@{
        "ComputerName" = hostname.exe
        "Manufacturer" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Manufacturer
        "Domain" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Domain
        "Model" = Get-WmiObject -Query "select * from Win32_ComputerSystem" | Select-Object -ExpandProperty Model
        "SerialNumber" = Get-WmiObject Win32_BIOS | Select-Object -ExpandProperty SerialNumber | Select-String -Pattern "1"
        "InstalledRAM" = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
        "ProcessorName" = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*" | Select-Object -ExpandProperty Name
        "ProcessorCount" = Get-CimInstance -ClassName Win32_Processor |  Select-Object -ExpandProperty NumberOfCores
        "HostOS" = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption
        "AvailableSpace" = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Measure-Object -Property Size -Sum | Select-Object -Property @{Expression={$_.Sum / 1GB};Label="Sum"} | Select-Object -ExpandProperty Sum
        "BIOSVersion" = Get-CimInstance -ClassName Win32_Bios | Select-Object -ExpandProperty SMBIOSBIOSVersion
        # "LoggedOnUser" = Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName | Select-Object -ExpandProperty UserName
    }
}

Export-CSV -Path $Path -InputObject InventoryDetails