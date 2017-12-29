<#
.SYNOPSIS
    Takes a list of SAMAccountNames and outputs information about the users
.PARAMETER users
    A list of users to pull info
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [string]$users
)

Import-Module ActiveDirectory

foreach($user in $users){
     Get-ADUser $user -Properties * | Select-Object -Property SamAccountName,DisplayName,Description
}