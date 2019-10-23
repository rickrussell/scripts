# vi:syntax=ps1
# file=domain_apps_devops.ps1
# Description: Use for domain joined PC's NOT for home or private use.
# Author: Rick Russell <sysadmin.rick@gmail.com>

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
Import-Module Boxstarter.Bootsrapper
Write-BoxstarterMessage "*** Imported Boxstarter Modules ***"

# Package installation using Chocolatey

Write-Host "** Installing base apps **" -ForegroundColor White -BackgroundColor Green
$apps = @(
  # For Hyper-V VM's:
  "Microsoft-Hyper-V-All -source windowsFeatures"
  "Microsoft-Windows-Subsystem-Linux -source windowsfeatures"
  #adobereader, java 8 runtime, 7zip, chrome, firefox etc
  "7zip.install"
  "sumatrapdf"
  "firefox"
  "googlechrome"
  "atom"
  "curl"
  "git-credential-manager-for-windows"
  "git -params '/GitAndUnixToolsOnPath /WindowsTerminal'"
  "poshgit"
  "powershellhere"
  # Languages
  # "golang"
  # "nodejs"
  # "Python"
  # "ruby"
  ## Docker
  "docker"
  "docker-for-windows"
  "docker-compose"
  "docker-kitematic"
  ## vagrant
  # "virtualbox"
  # "vagrant"
  ## kubernetes
  # "kubernetes-cli"
  # "minikube"
  ## Other tools
  "etcher"
  "kitty"
  "openssh"
  "wireshark"
  "winscp.install"
  "inconsolata"
  "dejavufonts"
  "sourcecodepro"
  "robotofonts"
  "droidfonts"
)

foreach ($app in $apps) {
    Write-Host "Adding $app" -ForegroundColor White -BackgroundColor Green
    cup -y $app
}

Write-Host "DevOps and Power User applications installed." -ForegroundColor White -BackgroundColor Green
