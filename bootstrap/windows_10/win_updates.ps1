# vi:syntax=ps1
# file=win_update.ps1
# Description: Windows 10 Provisioning using Boxstarter
# Author: Rick Russell <sysadmin.rick@gmail.com>

# Enable Debug output
# Set-PSDebug -Trace 1
# Bypass execution policy for local user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

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

# Kick off Windows Updates
Enable-PSRemoting
Write-BoxstarterMessage "Kicking off Windows Updates"
Install-WindowsUpdate -acceptEula
Enable-MicrosoftUpdate
Disable-PSRemoting

# Reset execution policy
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
