<#
.SYNOPSIS
    Displays some specs about a remote machine
.PARAMETER ComputerName
    The computer to query
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [string]$ComputerName
)

if(Test-Connection -Quiet -Count 1 -ComputerName $ComputerName) {
    $computerSystem = Get-CimInstance CIM_ComputerSystem -ComputerName $ComputerName
    $computerBIOS = Get-CimInstance CIM_BIOSElement -ComputerName $ComputerName
    $computerOS = Get-CimInstance CIM_OperatingSystem -ComputerName $ComputerName
    $computerCPU = Get-CimInstance CIM_Processor -ComputerName $ComputerName
    $computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'" -ComputerName $ComputerName

    $info = New-Object System.Collections.Specialized.OrderedDictionary
    $info.Add("Manufacturer", $computerSystem.Manufacturer)
    $info.Add("Model", $computerSystem.Model)
    $info.Add("Serial Number", $computerBIOS.SerialNumber)
    $info.Add("CPU", $computerCPU.Name)
    $info.Add("HDD Capacity", "{0:N2}" -f ($computerHDD.Size/1GB) + "GB")
    $info.Add("HDD Space", "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)")
    $info.Add("RAM", "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB")
    $info.Add("Operating System", $computerOS.caption + ", Service Pack: " + $computerOS.ServicePackMajorVersion)
    $info.Add("User logged In", $computerSystem.UserName)
    $info.Add("Last Reboot", $computerOS.LastBootUpTime)
    
    $info
} else {
    Write-Host "Unable to ping $ComputerName"
}
