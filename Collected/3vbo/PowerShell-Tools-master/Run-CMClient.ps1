<#
.SYNOPSIS
	Runs CCM update actions on remote machine
.DESCRIPTION
	Runs CCM update actions on remote machine by using SMS_Client.TriggerSchedule()
.PARAMETER  ComputerNames
	Name(s) of computer(s) to run the actions on
.EXAMPLE
	PS C:\> Run-CMClient.ps1 -ComputerNames localhost
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
	[string[]]$ComputerNames
)
$actions = '{00000000-0000-0000-0000-000000000021}', '{00000000-0000-0000-0000-000000000003}', '{00000000-0000-0000-0000-000000000121}',`
	'{00000000-0000-0000-0000-000000000001}', '{00000000-0000-0000-0000-000000000108}',	'{00000000-0000-0000-0000-000000000113}',`
	'{00000000-0000-0000-0000-000000000002}'
foreach($ComputerName in $ComputerNames){
	Write-Verbose "Running actions on $ComputerName"
	foreach($action in $actions){
		Invoke-WmiMethod -ComputerName $ComputerName -Namespace root\CCM -Class SMS_Client -Name TriggerSchedule -ArgumentList "$action"
	}
	Write-Verbose "Completed actions on $ComputerName"
}