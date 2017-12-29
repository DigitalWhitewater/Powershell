<#
.SYNOPSIS
   Removes specified KB(s) from machine(s)
.DESCRIPTION
   Calls PsExec to run wusa uninstall. Requires PsExec to be in C:\Sysinternals
.PARAMETER ComputerNames
   Mandatory. List of computer names, pipeline allowed
.PARAMETER KBs
   Mandatory. KB you wish to uninstall. Syntax is KB######
.EXAMPLE
   Remove-KB.ps1 –ComputerNames CompName –KB KB3085515
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
	[Alias('hostname')]
	[string[]]$ComputerNames,
	
	[Parameter(Mandatory=$True)]
	[Alias('hotfix')]
	[string[]]$KB
	)
	
foreach($Computer in $ComputerNames){
	$HotFix = Get-HotFix  -ComputerName $Computer | Where-Object {$_.HotfixID -eq $KB}
	if($HotFix) {
		$HotFixNum= $KB.Replace("KB","")
		C:\Sysinternals\PsExec -s \\$Computer wusa /uninstall /KB:$HotFixNum /quiet /norestart
		Write-Host "Script completed. If WUSA returns error 3010, computer needs to be restarted"
	} else {
		Write-Host "$Hotfix is not installed on target system"
	}
}
