# vi:syntax=ps1
# file=remove_base_services.ps1
# Description: Remove Windows 10 services we don't need
# Author: Rick Russell <sysadmin.rick@gmail.com>

# Enable Debug output
# Set-PSDebug -Trace 1

# Make sure we've run pre-reqs
# & "$PSScriptRoot\pre-reqs.ps1"

# Run Boxstarter Shell as an Administrator
$_boxstarter_path = 'C:\ProgramData\Boxstarter\BoxstarterShell.ps1'
$cwd = "$(Get-Location)"
. $_boxstarter_path
cd "$cwd"

# --- Make sure we've imported the Boxstarter modules we want ---
Import-Module Boxstarter.Chocolatey
Import-Module Boxstarter.WinConfig
Import-Module Boxstarter.Bootstrapper
Write-BoxstarterMessage "*** Imported Boxstarter Modules ***"

# Make sure we've run pre-reqs
# & "$PSScriptRoot\pre-reqs.ps1"

$services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
    "fdPHost"                                  # Function Discovery host
    "HomeGroupListener"                        # HomeGroup Listener
    "HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "MSISCSI"                                  # Virtual SCSI adapter
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "PeerDistSvc"                              # BranchCache
    "PNRPAutoReg"                              # P2P
    "p2pimsvc"                                 # P2P
    "p2psvc"                                   # P2P
    "PNRPsvc"                                  # P2P
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "SNMPTRAP"                                 # SNMP: not used on workstations
    "SysMain"                                  # AKA SuperFetch
    "TabletInputService"                       # Tablet Input Service
    "TapiSrv"                                  # Telephony API
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service (required for Fingerprint reader / facial detection)
    #"WlanSvc"                                 # WLAN AutoConfig
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "wscsvc"                                   # Windows Security Center Service
    #"WSearch"                                 # Windows Search
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service
    # Services which cannot be disabled
    #"WdNisSvc"
)

foreach ($service in $services) {
  Write-Host "Trying to disable $service" -ForegroundColor White -BackgroundColor DarkGreen
    Get-Service -Name $service | Set-Service -StartupType Disabled
}
