<#
.SYNOPSIS
    Stops Windows 7 and 10 from registering itself in DNS, allowing DNS to manage IPs instead
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

$NICs = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

foreach($NIC in $NICs) {
    try {
        $dhcp = $nic.GetIPProperties().GetIPv4Properties().IsDhcpEnabled
        if ($dhcp) {
            $wnic = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object -FilterScript {$_.Description -eq $nic.Description}
            $status = $wnic.SetDynamicDNSRegistration($false,$false).ReturnValue
            if ($status -eq 0){
                Write-Output "Set $($nic.Description) to not register itself with DNS" >> C:\DnsScriptLog.txt
            } else {
                Write-Output "Setting $($nic.Description) failed with error code $status" >> C:\DnsScriptLog.txt
            }
        }
    }
    catch {
        continue
    }
}
