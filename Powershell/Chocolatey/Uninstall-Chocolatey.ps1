# Description: Uninstall chocolately with RSO
# Version 1.0
# Author(s): Adam Gourley
# RSO Type: Action
# Notes: Due to the fragile nature of env variables, this script does not remove the variables
#        associated with Chocolatey. They can be removed manually if needed, but it is not a necessity.

if ($env:ChocolateyInstall) {
    $hostname = hostname.exe
    Write-Host "Removing Chocolatey from $hostname"

    # Remove the Chocolatey directory
    Remove-Item -Path $env:ChocolateyInstall -Recurse -Force
} else {
    Write-Host "Chocolatey home not found. It likely is not installed on this host."
}