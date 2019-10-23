# vi:syntax=ps1
# file=domain_apps_base.ps1
# Description: Base Applications for all domain joined Workstations. Use for
# domain joined PC's NOT for home or private use.
# Author: Rick Russell <sysadmin.rick@gmail.com>

# Enable Debug output
# Set-PSDebug -Trace 1

# Make sure we've run pre-reqs
# & "$PSScriptRoot\pre-reqs.ps1"

# Check if BoxStarter is installed, if not, install
$_boxstarter_path = 'C:\ProgramData\Boxstarter\BoxstarterShell.ps1'
if (!(Test-Path $_boxstarter_path)) {
    # Using Powershell v2 invoke here, to support Windows 7 machines
    iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); get-boxstarter -Force
}
# Then use same path to start Boxstarter Shell as an Administrator
$cwd = "$(Get-Location)"
. $_boxstarter_path
cd "$cwd"

# --- Make sure we've imported the Boxstarter modules we want ---
Import-Module Boxstarter.Chocolatey
Import-Module Boxstarter.WinConfig
Import-Module Boxstarter.Bootstrapper
Write-BoxstarterMessage "** Import Boxstarter Modules **"

Write-Host "** Installing base apps **" -ForegroundColor White -BackgroundColor Green
$apps = @(
  "chocolatey"
  "powershell"
  # Microsoft Visual C++ Runtime 2005
  "vcredist2005"
  # Microsoft Visual C++ Runtime 2008
  "vcredist2008"
  # Microsoft Visual C++ Runtime 2010
  "vcredist2010"
  # Microsoft Visual C++ Runtime 2012
  "vcredist2012"
  # Microsoft Visual C++ Runtime 2013
  "vcredist2013"
  # Microsoft Visual C++ Runtime 2015
  "vcredist2015"
  # Microsoft Visual C++ Runtime 2017
  "vcredist140"
  # Microsoft Native SQL Client - 2012
  "sql2012.nativeclient"
  # Microsoft .NET 4.6.1
  "dotnet4.6.2"
)

foreach ($app in $apps) {
    Write-Host "Installing or upgrading $app" -ForegroundColor White -BackgroundColor Green
    cup -y --cacheLocation="$ChocoCachePath" $app
}

Write-Host "Base set of applications installed." -ForegroundColor White -BackgroundColor Green
