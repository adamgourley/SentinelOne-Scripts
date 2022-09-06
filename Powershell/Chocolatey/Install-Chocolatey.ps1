# Description: Install chocolately with RSO
# Version 1.0
# Author(s): Adam Gourley
# RSO Type: Action

function checkConnection {
    # Requests response from Chocolatey website; returns true or false.
    $HTTP_Request = [System.Net.WebRequest]::Create('https://community.chocolatey.org')
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    if ($HTTP_Status -eq 200) {
        Write-Host "Connection to https://community.chocolatey.org is up."
        return $true
    } else {
        Write-Host "Unable to connect to https://community.chocolatey.org. The site may be down, or the connection is blocked."
        return $false
    }
}

if (checkConnection) {
    # Install chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Installation complete."
} else {
    # Unable to connect, so exit script.
    Write-Host "Installation never begun. Could not download installation file."
    exit
}