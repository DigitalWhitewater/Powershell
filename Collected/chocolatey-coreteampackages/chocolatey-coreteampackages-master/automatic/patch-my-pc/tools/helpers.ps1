﻿function Install-ChocolateyPinnedItem {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$target,
    [string]$taskbar
  )

  # We need to know the translation for the Explorer context-menu item for pinning an item to the start-menu or taskbar.
  # Be careful. Commands vary from Windows version to version. E.g. Win7 -> Startmenu; Win8 -> Start;
  # We need loose matching. So we want to match the action (Pin) and the target (Start(menu) or Task(bar)) separately.

  # Translations
  # PLEASE ADD LANGUAGES
  # or even better, figure out a way to pin items to start without using this MONSTROUS trick.

  # Pin (to start)
  $verbPin = @{}
  $verbPin['da-DK'] = "Fastgør"
  $verbPin['en-US'] = "Pin"
  $verbPin['fi-FI'] = "Kiinnitä"
  $verbPin['nb-NO'] = "Fest"
  $verbPin['nl-NL'] = "Vastmaken"
  $verbPin['sv-SE'] = "Fäst"

  # (Pin to) Start
  $verbStart = @{}
  $verbStart['da-DK'] = "Start"
  $verbStart['en-US'] = "Start"
  $verbStart['fi-FI'] = "Käynnistä"
  $verbStart['nb-NO'] = "Start"
  $verbStart['nl-NL'] = "Start"
  $verbStart['sv-SE'] = "Start"

  # (Pin to) Taskbar
  $verbTask = @{}
  $verbTask['da-DK'] = "Proceslinje"
  $verbTask['en-US'] = "Task"
  $verbTask['fi-FI'] = "Tehtävälkkiin"
  $verbTask['nb-NO'] = "Oppgavelinjen"
  $verbTask['nl-NL'] = "Taak"
  $verbTask['sv-SE'] = "Aktivitetsfältet"

  # Get Locale
  $locale = (get-culture).Name
  # Not sure if get-culture < Windows 8, better not use

  # Switch for Taskbar instead of Start
  if ($taskbar -eq "") {
    $verbAction = $verbStart
  } else {
    $verbAction = $verbTask
  }

  # Path exists?
  if (-not (test-path "$target")) {
    Write-Output "No such file: '$target'";
    exit
  }

  $pinned   = $false
  $path     = split-path "$target"
  $file     = split-path "$target" -leaf
  $explorer = new-object -com "Shell.Application"
  $folder   = $explorer.nameSpace($path)
  $item     = $folder.parseName($file)
  $options  = $item.Verbs()	# > $null # This will still output irrelevant warnings for certain context menu items such as github. How to I hide these?

  foreach ($option in $options) {
    $oName = $option.Name.Replace("&","")

    # Be careful. Commands vary from Windows version to version. E.g. Win7 -> Startmenu; Win8 -> Start;
    # We need loose matching.
    # WARNING - This trick might also cause UNpinning if $file was already pinned!

    # First, match Pin
    foreach ($vPin in $verbPin.values) {
      if ($oName -imatch $vPin) {
        # Second, match action (either Start or Task(bar))
        foreach ($vAction in $verbAction.values) {
          if ($oName -imatch $vAction) {
            # Write-Output "Locale detected: $($vAction.key)" # Don't know key in values-foreach
            Write-Output "Command detected: $oName"
            Write-Output "Executing '$oName' for '$target'"
            $option.DoIt()
            $pinned = $true
            break
          }
        }
        if ($pinned) { break }
      }
    }
  }
  if ($pinned) { Write-Output "Succesfully Pinned '$file'" }
  else { Write-Output "Could not pin '$file'" }
}
