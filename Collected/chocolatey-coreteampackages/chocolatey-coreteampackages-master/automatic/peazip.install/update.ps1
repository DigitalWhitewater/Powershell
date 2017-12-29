import-module au

$releases = 'https://github.com/giorgiotani/PeaZip/releases'

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
  $url32  = $download_page.links | ? href -match 'WINDOWS.exe$' | select -First 1 -expand href
  $url64 = $download_page.links | ? href -match 'WIN64.exe$' | select -First 1 -expand href
  $version   = $url32 -split '-|.WINDOWS.exe' | select -Last 1 -Skip 1
  $version64   = $url64 -split '-|.WIN64.exe' | select -Last 1 -Skip 1

  if ($version -ne $version64) {
    throw "32-bit and 64-bit version do not match. Please investigate."
  }

  return @{
    URL32    = 'https://github.com' + $url32
    URL64    = 'https://github.com' + $url64
    Version  = $version
  }
}

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*file\s*=\s*`"[$]toolsDir\\).*" = "`${1}$($Latest.FileName32)`""
      "(?i)(^\s*file64\s*=\s*`"[$]toolsDir\\).*" = "`${1}$($Latest.FileName64)`""
      }
    ".\legal\VERIFICATION.txt" = @{
        "(?i)(32-Bit.+)\<.*\>" = "`${1}<$($Latest.URL32)>"
        "(?i)(64-Bit.+)\<.*\>" = "`${1}<$($Latest.URL64)>"
        "(?i)(checksum type:\s+).*" = "`${1}$($Latest.ChecksumType32)"
        "(?i)(checksum32:\s+).*" = "`${1}$($Latest.Checksum32)"
        "(?i)(checksum64:\s+).*" = "`${1}$($Latest.Checksum64)"
    }
  }
}

update -ChecksumFor none
