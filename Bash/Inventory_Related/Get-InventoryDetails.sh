#!/bin/bash
# This script is used to gather system details, for inventorying purposes.
# Version 1.0
# Author(s): Adam Gourley
# RSO Type: Artifact Collection

# Get system details
SystemDate=$(date +"%m-%d-%y %H:%M:%S")
ComputerName=$(uname -n)
Manufacturer=$(cat /sys/class/dmi/id/board_vendor)
Domain=$(hostname -d)
Model=$(sudo dmidecode -s baseboard-product-name)
SerialNumber=$(sudo dmidecode -s system-serial-number)
InstalledRAM=$(free -g | grep Mem: | awk '{print $2}')
ProcessorName=$(cat /proc/cpuinfo  | grep 'name'| uniq | awk '{print $4, $5, $6, $7, $8, $9, $10}')
ProcessorCount=$(lscpu -ap | grep -v '^#' | awk -F, '{ print $2 }' | sort -nu | wc -l)
ProcessorThreadCount=$(lscpu | grep -i '^cpu(s)' | sed -n 's/^.\+:[[:blank:]]*//p')
HostOS=$(hostnamectl | grep "Operating System" | sed 's/[^:]*: *//; s/,.*//')
OSBuild=$(hostnamectl | grep "Kernel" | sed 's/[^:]*: *//; s/,.*//')
AvailableSpace=$(df -H -x squashfs --total | grep total | awk '{print $2}')
UsedSpace=$(df -H -x squashfs --total | grep total | awk '{print $4}')
BIOSVersion=$(cat /sys/class/dmi/id/bios_version)
IPAddress=$(hostname -I | awk '{print $1}')
MACAddress=$(cat /sys/class/net/eth0/address)
LoggedOnUser=$(logname)

# Output to console or CSV based off -o flag.
if [ "$1" == "-o" ] && [ $2 ]; then
    echo "Writing output to CSV..."

    # Write two rows, results and headers
    echo "SystemDate,ComputerName,Manufacturer,Domain,Model,SerialNumber,InstalledRAM,ProcessorName,ProcessorCount,ProcessorThreadCount,HostOS,OSBuild,AvailableSpace,UsedSpace,BIOSVersion,IPAddress,MACAddress,LoggedOnUser" >> $2
    echo "$SystemDate,$ComputerName,$Manufacturer,$Domain,$Model,$SerialNumber,$InstalledRAM,$ProcessorName,$ProcessorCount,$ProcessorThreadCount,$HostOS,$OSBuild,$AvailableSpace,$UsedSpace,$BIOSVersion,$IPAddress,$MACAddress,$LoggedOnUser" >> $2 

elif [ "$1" == "-o" ] && [ -z $2 ]; then
    echo "You must supply a path to save the file to after the '-o' flag."
else
    echo -e "Writing output to console..."
    echo -e "If you would rather export the results to a CSV, use the '-o' flag, following with the desired path.\n"
    echo -e "SystemDate=$SystemDate\nComputerName=$ComputerName\nManufacturer=$Manufacturer\nDomain=$Domain\nModel=$Model\nSerialNumber=$SerialNumber\nInstalledRAM=$InstalledRAM\nProcessorName=$ProcessorName\nProcessorCount=$ProcessorCount\nProcessorThreadCount=$ProcessorThreadCount\nHostOS=$HostOS\nOSBuild=$OSBuild\nAvailableSpace=$AvailableSpace\nUsedSpace=$UsedSpace\nBIOSVersion=$BIOSVersion\nIPAddress=$IPAddress\nMACAddress=$MACAddress\nLoggedOnUser=$LoggedOnUser"
fi