<#
.SYNOPSIS
    A module of useful functions. Typically sourced by PSProfile
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

function Get-Time {return $(Get-Date | ForEach {$_.ToLongTimeString()})}

function prompt {
    Write-Host "[" -noNewLine
    Write-Host $(Get-Time) -ForegroundColor DarkYellow -noNewLine
    Write-Host "] " -noNewLine
    Write-Host $($(Get-Location).Path.replace($home,"~")) -ForegroundColor DarkGreen -noNewLine
    Write-Host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
    return "> "
}
 
function ll {
    param ($dir = ".", $all = $false)
 
    $origFg = $Host.UI.RawUI.ForegroundColor
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }
 
    foreach ($Item in $toList)
    {
        Switch ($Item.Extension)
        {
            ".exe" {$Host.UI.RawUI.ForegroundColor="DarkYellow"}
            ".hta" {$Host.UI.RawUI.ForegroundColor="DarkYellow"}
            ".cmd" {$Host.UI.RawUI.ForegroundColor="DarkRed"}
            ".ps1" {$Host.UI.RawUI.ForegroundColor="DarkGreen"}
            ".html" {$Host.UI.RawUI.ForegroundColor="Cyan"}
            ".htm" {$Host.UI.RawUI.ForegroundColor="Cyan"}
            ".7z" {$Host.UI.RawUI.ForegroundColor="Magenta"}
            ".zip" {$Host.UI.RawUI.ForegroundColor="Magenta"}
            ".gz" {$Host.UI.RawUI.ForegroundColor="Magenta"}
            ".rar" {$Host.UI.RawUI.ForegroundColor="Magenta"}
            Default {$Host.UI.RawUI.ForegroundColor=$origFg}
        }
        if ($item.Mode.StartsWith("d")) {$Host.UI.RawUI.ForegroundColor="Gray"}
        $item
    }
    $Host.UI.RawUI.ForegroundColor = $origFg
}
 
function Edit-HostsFile {
    vim "$env:windir\system32\drivers\etc\hosts"
}

function whoami {
    [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}
 
function Update-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_) {
            Write-Verbose "Running $_"
            . $_
        }
    }    
}
 
function Check-SessionArch {
    if ([System.IntPtr]::Size -eq 8) {
        return "x64" 
    } else {
        return "x86" 
    }
}
 
function Test-Port {
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
        [string]$Target,

        [parameter(mandatory=$true)]
        [int32]$Port,

        [int32]$Timeout=2000
    )

    $outputobj=New-Object -TypeName PSobject
    $outputobj | Add-Member -MemberType NoteProperty -Name TargetHostName -Value $Target

    if(Test-Connection -ComputerName $Target -Count 2) {
        $outputobj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "ONLINE"
    } else {
        $outputobj | Add-Member -MemberType NoteProperty -Name TargetHostStatus -Value "OFFLINE"
    }
                    
    $outputobj | Add-Member -MemberType NoteProperty -Name PortNumber -Value $Port
    $Socket=New-Object System.Net.Sockets.TCPClient
    $Connection=$Socket.BeginConnect($Target,$Port,$null,$null)
    $Connection.AsyncWaitHandle.WaitOne($timeout,$false) | Out-Null

    if($Socket.Connected -eq $true) {
        $outputobj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Success"
    } else {
        $outputobj | Add-Member -MemberType NoteProperty -Name ConnectionStatus -Value "Failed"
    }
                
    $Socket.Close | Out-Null
    $outputobj | Select TargetHostName, TargetHostStatus, PortNumber, Connectionstatus | Format-Table -AutoSize
}

function Get-PortInfo {
    param (
        $ip,
        $port
    )
    $tester = New-Object Net.Sockets.TcpClient

    try {
        $tester.Connect($ip, $port)
    } catch {}

    if ($tester.Connected) {
        $tester.Close()
        $open = $true
    } else {
        $open = $false
    }

    [pscustomobject]@{
        IP = $ip
        Port = $port
        Open = $open
    }
}

Export-ModuleMember -Function Get-Time
Export-ModuleMember -Function prompt
Export-ModuleMember -Function ll
Export-ModuleMember -Function Edit-HostsFile
Export-ModuleMember -Function whoami
Export-ModuleMember -Function Update-Profile
Export-ModuleMember -Function Check-SessionArch
Export-ModuleMember -Function Test-Port
Export-ModuleMember -Function Get-PortInfo
