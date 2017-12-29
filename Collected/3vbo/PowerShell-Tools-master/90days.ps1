<#
.SYNOPSIS
   Prints any ADUser account that has not authenticated in 90 days to STDOUT
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>
Import-Module ActiveDirectory

Get-ADUser -Filter * -Properties "LastLogonDate" | Where-Object {$_.LastLogonDate -lt ((Get-Date).AddDays(-90))} | Where-Object {$_.Enabled -eq $False} | Select-Object Name,LastLogonDate