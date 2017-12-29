<#
.SYNOPSIS
    Deletes a User or User Group from the Local Admins group
.PARAMETER Computer
    The name of the computer
.PARAMETER User
    The user or user group to remove
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$Computer,
	
	[Parameter(Mandatory=$True)]
	[string]$user
)

$computer = [ADSI]("WinNT://" + $Computer + ", computer")
$group = $computer.psbase.children.find($user) 
$group.Remove("WinNT://ODOT/" + $user)
