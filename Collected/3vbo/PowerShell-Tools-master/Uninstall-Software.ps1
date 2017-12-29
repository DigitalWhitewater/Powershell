<#
.SYNOPSIS
	Uninstall software based on the name

.DESCRIPTION
	Uninstall software based on the name in the Registroy

.PARAMETER ApplicationName
	A description of the ApplicationName parameter.

.PARAMETER MSI_Switches
	The switches used when executing the uninstallation of the MSI

.EXAMPLE
	powershell.exe -executionpolicy bypass -windowstyle hidden -file Uninstall-Software.ps1 -ApplicationName "7-Zip"

.NOTES     
    Author: Evan Burkey, evan at burkey dot co
#>
[CmdletBinding()]
param
(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string]$ApplicationName,

		[string]$MSI_Switches = '/qn /norestart'
)

function Uninstall-MSIByName {
	[CmdletBinding()]
	param ()
	
	$Uninstall = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue
	$Uninstall += Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue
	$SearchName = "*" + $ApplicationName + "*"
	$Executable = $Env:windir + "\system32\msiexec.exe"
	Foreach ($Key in $Uninstall) {
		$TempKey = $Key.Name -split "\\"
		If ($TempKey[002] -eq "Microsoft") {
			$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + $Key.PSChildName
		} else {
			$Key = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + $Key.PSChildName
		}
		If ((Test-Path $Key) -eq $true) {
			$KeyName = Get-ItemProperty -Path $Key
			If ($KeyName.DisplayName -like $SearchName) {
				$TempKey = $KeyName.UninstallString -split " "
				If ($TempKey[0] -eq "MsiExec.exe") {
					Write-Host "Uninstall"$KeyName.DisplayName"....." -NoNewline
					$Parameters = "/x " + $KeyName.PSChildName + [char]32 + $MSI_Switches
					$ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Parameters -Wait -Passthru).ExitCode
					If (($ErrCode -eq 0) -or ($ErrCode -eq 3010) -or ($ErrCode -eq 1605)) {
						Write-Host "Success" -ForegroundColor Yellow
					} else {
						Write-Host "Failed with error code "$ErrCode -ForegroundColor Red
					}
				}
			}
		}
	}
}

Clear-Host
Uninstall-MSIByName
