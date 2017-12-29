<#
.SYNOPSIS
   Replaces all string instances in all files of specified name on C:
.PARAMETER filename
   Mandatory. Name of file(s) that need to have string replacements performed
.PARAMETER oldString
   Mandatory. String to replace
.PARAMETER newString
   Mandatory. Replacement string
.EXAMPLE
   Change-TextFile.ps1 "C:\test.txt" "Old String" "New String"
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$filename,
	
	[Parameter(Mandatory=$True)]
	[string]$oldString,

    [Parameter(Mandatory=$True)]
    [string]$newString
)

$files = get-childitem -Path C:\ -Filter $filename -Recurse -ErrorAction SilentlyContinue

foreach($file in $files){
    $path = $file | select -ExpandProperty FullName
    Write-Verbose "Changing $path"
    (Get-Content -Path "$path").Replace($oldString, $newString) | Set-Content "$path"
    Write-Verbose "$path changed"
}
