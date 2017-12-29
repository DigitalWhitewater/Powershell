<#
.SYNOPSIS
   Run to add "Open PowerShell as Administrator" to the right-click menu in Windows
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

$menu = 'Open PowerShell here as Administrator'
$ps = "$PSHOME\powershell.exe -NoExit -Command ""Set-Location '%V'"""

'directory', 'directory/background', 'drive' | ForEach-Object {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\$_\shell" -Name runas\command -Force |
    Set-ItemProperty -Name '(default)' -Value $ps -PassThru |
    Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $menu -PassThru |
    Set-ItemProperty -Name HasLUAShield -Value ''
}