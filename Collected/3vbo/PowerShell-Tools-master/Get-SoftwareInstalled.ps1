<#
.SYNOPSIS
    Outputs all registered software on a given computer
.PARAMETER Computer
    The computer to query
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [string]$Computer
)

$colItems = get-wmiobject -class "Win32_Product" -namespace "root\CIMV2" -computername $Computer 
foreach ($objItem in $colItems) {write-host "$($objItem.Name)",$($objItem.Version)} 