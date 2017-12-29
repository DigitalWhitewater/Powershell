#Uses WMI to install the print driver	
Function InstallPrinterDriver {
	Param ($DriverName, $DriverPath, $DriverInf, $Arch)
	$wmi = [WMICLASS]"\\.\ROOT\cimv2:Win32_PrinterDriver"
	$wmi.psbase.scope.options.enablePrivileges = $true
	$wmi.psbase.Scope.Options.Impersonation = `
	[System.Management.ImpersonationLevel]::Impersonate
	$Driver = $wmi.CreateInstance()
	$Driver.Name = $DriverName
	$Driver.DriverPath = $DriverPath
	$Driver.InfName = $DriverInf
	$Driver.SupportedPlatform = $Arch
	$wmi.AddPrinterDriver($Driver)
	$wmi.Put()
}

#Uses WMI to create an IP Printer Port
Function PortInstall { 
	param ($PortName,$PrinterIP) 

	$PPrinter = ([WMIClass]"\\.\ROOT\cimv2:Win32_TcpIpPrinterPort").CreateInstance() 
	$PPrinter.name = $PortName 
	$PPrinter.Protocol = 1 
	$PPrinter.HostAddress = $PrinterIP 
	$PPrinter.PortNumber = 9100 
	$PPrinter.Put() 
} 

#Uses WMI to create an IP Printer on a Port
Function PrinterInstall { 
	param ($Caption,$PortName,$DriverName,$IsDefault = $false) 
	
	$iprinter = ([WMIClass]"\\.\Root\cimv2:Win32_Printer").CreateInstance() 
	$iprinter.Caption =$caption 
	$iprinter.DriverName =$DriverName 
	$iprinter.PortName =$PortName
	$iprinter.DeviceID =$caption 
	$iprinter.Default = $IsDefault 
	$iprinter.Put() 
}

$DriverName = 'Name of Driver'
$DriverPath = "Path\To\Driver"
$DriverINF = "\Path\To\Driver\driver.inf"
InstallPrinterDriver -DriverPath $DriverPath -DriverInf $DriverINF -DriverName $DriverName -Arch "Windows x64"
PortInstall -PortName "Port Name" -PrinterIP "IP Address of Printer"
PrinterInstall -Caption "My Printer" -PortName "Port Name" -DriverName $DriverName -IsDefault $true
