<#
.SYNOPSIS
   Gets date that Windows was installed on remote machine
.PARAMETER computername
   Mandatory. Name of PC to check
.EXAMPLE
   Get-InstallDate WINCOMP
.NOTES
    Author: Evan Burkey <evan@burkey.co>
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [Alias('hostname')]
    [string]$computername
)

$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername)
$RegKey= $Reg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion")
$installRaw = $RegKey.GetValue("InstallDate")

if ($installRaw -ne $null)
{
    $startDate = [System.DateTime]::new(1970, 1, 1, 0, 0, 0);
    $regVal = [System.Convert]::ToInt64($installRaw)

    Write-Host $startDate.AddSeconds($regVal)
}
else {
    Write-Output "No install date in remote registry"
}

