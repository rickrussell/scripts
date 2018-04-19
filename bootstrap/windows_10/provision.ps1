# Description: Boxstarter Script
# Author: Rick Russell <rickr@noneck.net>
# Last Updated: 2018-04-18
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher
# heavily borrowed from Jessie, but I just have to tweak some things for my boxen. I have a couple of things I use for work,
# a couple of things I use for home. this includes a bunch of core optimizations i've picked up over the years...
# little things... small, exlusively paranoid things...
# Use Chocolatey Upgrade (cup) instead of Install (cinst) as Upgrade Installs package if not found. -RRR

# From an Administrator PowerShell, if Get-ExecutionPolicy returns Restricted, run:
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy Unrestricted -Force
}

# Check if BoxStarter is installed, if not, install
$_boxstarter_path = 'C:\ProgramData\Boxstarter\BoxstarterShell.ps1'
if (!(Test-Path $_boxstarter_path)) {
    . { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
}

# Then run: Boxstarter Shell as an Administrator
# $cwd = "$(Get-Location)"
# . $_boxstarter_path
# cd "$cwd"

#---- TEMPORARY ---
Disable-UAC
Disable-MicrosoftUpdate

# Make sure we've imported the Boxstarter modules we want
Import-Module Boxstarter.Chocolatey
Import-Module Boxstarter.WinConfig
Import-Module Boxstarter.Bootsrapper

Write-BoxstarterMessage "***Disabling Useless Services***"
# There are some services that you simply do not need if you want to lay low. go spelunking in the Services.msc to see why.
# you are not pulling from shares, you should not expose shares...die LAN Man! with my last breath I will curse thee
Set-service -Name LanmanServer -StartupType Disabled
#print spooler: Dead
Set-service -Name Spooler -StartupType Disabled
# Tablet input: pssh nobody use tablet input. its silly.just write right in onenote
Set-service -Name TabletInputService -StartupType Disabled
# Telephony API is tell-a-phony
Set-service -Name TapiSrv -StartupType Disabled
#geolocation service : u can't find me.
Set-service -Name lfsvc -StartupType Disabled
# ain't no homegroup here.
Set-service -Name HomeGroupProvider -StartupType Disabled
# u do not want ur smartcard cert to propagate to the local cache, do you?
Set-service -Name CertPropsvc -StartupType Disabled
# who needs branchcache?
Set-service -Name PeerDistSvc -StartupType Disabled
# i don't need to keep links from NTFS file shares across the network - i haz office.
Set-service -Name TrkWks -StartupType Disabled
# i don't use iscsi
Set-service -Name MSISCSI -StartupType Disabled
# why is SNMPTRAP still on windows 10? i mean, really, who uses SNMP? is it even a real protocol anymore?
Set-service -Name SNMPTRAP -StartupType Disabled
# Peer to Peer discovery svcs...Begone!
Set-service -Name PNRPAutoReg -StartupType Disabled
Set-service -Name p2pimsvc -StartupType Disabled
Set-service -Name p2psvc -StartupType Disabled
Set-service -Name PNRPsvc -StartupType Disabled
# no netbios over tcp/ip. unnecessary.
Set-service -Name lmhosts -StartupType Disabled
# this is like plug & play only for network devices. no thx. k bye.
Set-service -Name SSDPSRV -StartupType Disabled
# YOU DO NOT NEED TO PUBLISH FROM THIS DEVICE. Discovery Resource Publication service:
Set-service -Name FDResPub -StartupType Disabled
#"Function Discovery host provides a uniform programmatic interface for enumerating system resources" - NO THX.
Set-service -Name fdPHost -StartupType Disabled
#intel Proset wireless registry thing. curse thee:
Set-service -Name RegSrvc -StartupType Disabled
#optimize the startup cache...i think. on SSD i don't think it really matters.
set-service SysMain -StartupType Automatic


#---LIBRARIES---
# this assumes you set up onedrive.
# Move-LibraryDirectory -libraryName "Personal" -newPath $ENV:OneDrive\Documents
# Move-LibraryDirectory -libraryName "My Pictures" -newPath $ENV:OneDrive\Pictures
# Move-LibraryDirectory -libraryName "My Video" -newPath $ENV:OneDrive\Videos
# Move-LibraryDirectory -libraryName "My Music" -newPath $ENV:OneDrive\Music

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Set-WindowsExplorerOptions `
    -EnableShowHiddenFilesFoldersDrives `
    -EnableShowProtectedOSFiles `
    -EnableShowFileExtensions `
    -EnableShowFullPathInTitleBar `
    -DisableOpenFileExplorerToQuickAccess `
    -DisableShowRecentFilesInQuickAccess `
    -DisableShowFrequentFoldersInQuickAccess

Set-TaskbarOptions -Size Large -Dock Bottom -Combine Full -AlwaysShowIconsOn

#--- Windows Subsystems/Features ---
# these are also available for scripting directly on windows and installing natively via Enable-WindowsOptionalFeature.
# if you wanna know what's available, try this:
# Get-WindowsOptionalFeature  -Online | sort @{Expression = "State"; Descending = $True}, @{Expression = "FeatureName"; Descending = $False}| Format-Table -GroupBy State

# Package installation using Chocolatey

# Virtuals only:
# cup -y Microsoft-Hyper-V-All -source windowsFeatures

cup -y chocolatey
cup -y powershell

refreshenv

#--- Tools ---
#
Write-BoxstarterMessage "***Installing Tools***"
#GIT
cup -y git -params '"/GitAndUnixToolsOnPath /WindowsTerminal"' -y
cup -y poshgit
cup -y github
cup -y git-credential-manager-for-windows

refreshenv

# sysinternals bad, mkay? this only runs on VMs, mkay?
#choco install sysinternals -y
cup -y atom
cup -y curl
cup -y kitty
cup -y winscp.install
cup -y 7zip.install
cup -y powershellhere
cup -y powershell
cup -y wireshark
cup -y etcher
cup -y openssh #-params '"/SSHServerFeature"'

refreshenv

Write-BoxstarterMessage "***Installing Ruby, Python, Go, NodeJS, Vagrant and Docker***"
cup -y ruby
cup -y nodejs
cup -y Python
cup -y golang
cup -y virtualbox
cup -y vagrant
cup -y docker
cup -y docker-for-windows
cup -y docker-compose
cup -y docker-kitematic
# kubernetes
# cup -y kubernetes-cli
# cup -y minikube

refreshenv

Write-BoxstarterMessage "***Installing Extra Fonts***"
#---- Fonts ----
cup -y inconsolata
cup -y dejavufonts
cup -y sourcecodepro
cup -y robotofonts
cup -y droidfonts
cup -y noto

refreshenv

#Adobe, java, & firefox is malware, but i included it here, because some of you insist and will never learn.
cup -y adobereader
cup -y flashplayerplugin
cup -y jre8
cup -y firefox
cup -y googlechrome
cup -y adblockplusie

refreshenv

# Microsoft Apps
#cup -y office365proplus
#cup -y microsoft-teams
cup -y vcredist140

refreshenv

#--- Uninstall unecessary applications that come with Windows out of the box ---
Write-BoxstarterMessage "*** Store Apps Cleanup ***"

$apps = @(
   # Give no quarter to these skallywags!
   # default Windows 10 apps
   "Microsoft.3DBuilder"
   "Microsoft.Appconnector"
   "Microsoft.BingFinance"
   "Microsoft.BingNews"
   "Microsoft.BingSports"
   "Microsoft.BingWeather"
   #"Microsoft.FreshPaint"
   "Microsoft.Getstarted"
   "Microsoft.MicrosoftOfficeHub"
   "Microsoft.MicrosoftSolitaireCollection"
   "Microsoft.MicrosoftStickyNotes"
   "Microsoft.Office.OneNote"
   "Microsoft.OneConnect"
   "Microsoft.People"
   "Microsoft.SkypeApp"
   "Microsoft.Windows.Photos"
   "Microsoft.WindowsAlarms"
   #"Microsoft.WindowsCalculator"
   "Microsoft.WindowsCamera"
   "Microsoft.WindowsMaps"
   "Microsoft.WindowsPhone"
   "Microsoft.WindowsSoundRecorder"
   #"Microsoft.WindowsStore"
   "Microsoft.XboxApp"
   "Microsoft.ZuneMusic"
   "Microsoft.ZuneVideo"
   "microsoft.windowscommunicationsapps"
   "Microsoft.MinecraftUWP"
   "Microsoft.MicrosoftPowerBIForWindows"
   "Microsoft.NetworkSpeedTest"

   # Threshold 2 apps
   "Microsoft.CommsPhone"
   "Microsoft.ConnectivityStore"
   "Microsoft.Messaging"
   "Microsoft.Office.Sway"
   "Microsoft.OneConnect"
   "Microsoft.WindowsFeedbackHub"

   #Redstone apps
   "Microsoft.BingFoodAndDrink"
   "Microsoft.BingTravel"
   "Microsoft.BingHealthAndFitness"
   "Microsoft.WindowsReadingList"

   # non-Microsoft
   "9E2F88E3.Twitter"
   "PandoraMediaInc.29680B314EFC2"
   "Flipboard.Flipboard"
   "ShazamEntertainmentLtd.Shazam"
   "king.com.CandyCrushSaga"
   "king.com.CandyCrushSodaSaga"
   "king.com.*"
   "ClearChannelRadioDigital.iHeartRadio"
   "4DF9E0F8.Netflix"
   "6Wunderkinder.Wunderlist"
   "Drawboard.DrawboardPDF"
   "2FE3CB00.PicsArt-PhotoStudio"
   "D52A8D61.FarmVille2CountryEscape"
   "TuneIn.TuneInRadio"
   "GAMELOFTSA.Asphalt8Airborne"
   "TheNewYorkTimes.NYTCrossword"
   "DB6EA5DB.CyberLinkMediaSuiteEssentials"
   "Facebook.Facebook"
   "flaregamesGmbH.RoyalRevolt2"
   "Playtika.CaesarsSlotsFreeCasino"
   "A278AB0D.MarchofEmpires"
   "KeeperSecurityInc.Keeper"
   "ThumbmunkeysLtd.PhototasticCollage"
   "XINGAG.XING"
   "89006A2E.AutodeskSketchBook"
   "D5EA27B7.Duolingo-LearnLanguagesforFree"
   "46928bounde.EclipseManager"
   "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
   "CAF9E577.Plex"
   "*Dropbox*"

   # apps which cannot be removed using Remove-AppxPackage
   #"Microsoft.BioEnrollment"
   #"Microsoft.MicrosoftEdge"
   #"Microsoft.Windows.Cortana"
   #"Microsoft.WindowsFeedback"
   #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
   #"Windows.ContactSupport"
)

foreach ($app in $apps) {
   Write-Output "Trying to remove $app"

   Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

   Get-AppXProvisionedPackage -Online |
       Where-Object DisplayName -EQ $app |
       Remove-AppxProvisionedPackage -Online -AllUsers
}

#---- Windows Settings ----
# Some from: @NickCraver's gist https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

# # Privacy: Let apps use my advertising ID: Disable
# If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
#    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
# }
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0
#
# # WiFi Sense: HotSpot Sharing: Disable
# If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
#    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
# }
# Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0
#
# # WiFi Sense: Shared HotSpot Auto-Connect: Disable
# Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0
#
# # Start Menu: Disable Bing Search Results
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
# # To Restore (Enabled):
# # Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1
#
# # Better File Explorer
# # Disable Quick Access: Recent Files
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
# # Disable Quick Access: Frequent Folders
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1
# # To Restore:
# # Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
# # Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1
# Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
# Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
# Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2
#
# # Lock screen (not sleep) on lid close
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1
# # To Restore:
# # Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 0


#--- Restore Temporary Settings ---
Write-BoxstarterMessage "re-Enable UAC"
Enable-UAC
Write-BoxstarterMessage "re-Enable Windows Update"
Enable-MicrosoftUpdate

Write-BoxstarterMessage "Setting Execution Policy to Restricted"
if ((Get-ExecutionPolicy) -eq "Unrestricted") {
    Set-ExecutionPolicy Restricted -Force
}

Write-BoxstarterMessage "Kicking off Windows Updates"
# Finally kick off updates!
Install-WindowsUpdate -acceptEula

#--- Rename the Computer ---
# Requires restart, or add the -Restart flag

# $computername = "UNDETECTED"
#
# if ($env:computername -ne $computername) {
#  Write-BoxstarterMessage "Renaming Computer to:  $computername "
#  Rename-Computer -NewName $computername
# }
Write-BoxstarterMessage "All finished! Your Machine is provisioned with the default set of apps!"
