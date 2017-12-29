<#
.SYNOPSIS
   Removes msxml4.dll and msxml4r.dll from local machine
.DESCRIPTION
   Recursively loops through the C:\Windows folder, looking for
   msxml4.dll or msxml4r.dll. After generating a list of all
   instances, removes them one by one.
.NOTES
    Author: Evan Burkey, evan at burkey dot co
#>

$targets = @("msxml4.dll", "msxml4r.dll")
$time = (Get-Date -Format "yyyy-MM-dd H:mm:ss").ToString()
$logstring = "$time    Removed: "

foreach ($target in $targets)
{
    $msxml_path = Get-ChildItem -Path C:\Windows -Filter $target -Recurse
    if ($msxml_path -ne $null)
    {
        foreach ($file in $msxml_path)
        {
            $path = $file | Select-Object -ExpandProperty FullName
            Remove-Item -Force -Path $path
            Write-Output "$logstring $path" >> "C:\Windows\Logs\Remove-MSXML.log"
        }
    }
}
