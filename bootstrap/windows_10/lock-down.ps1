# vi:syntax=ps1
# file=lock-down.ps1
# Description: Windows 10 Provisioning using Boxstarter
# Author: Rick Russell <sysadmin.rick@gmail.com>

# Enable Debug output
# Set-PSDebug -Trace 1

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

# # Make sure we prevent users on other computers from running commands on the local computer
# Write-BoxstarterMessage "Disable PSRemoting (external commands)"
# Disable-PSRemoting #-force > $null

# # Make sure to completely clean up after WinRM
# # https://blogs.technet.microsoft.com/bshukla/2011/04/27/how-to-revert-changes-made-by-enable-psremoting/
# # TODO: I'd like to use winRM w/ SSL certs on port 8596
# Write-BoxstarterMessage "** Running Through Steps Above as recommended **"
#
# # I've had trouble with completely removing the listener, we disable the service below for now -RRR
# # # TODO: Additional Testing needed
# Write-BoxstarterMessage "Stop & Disable WinRM Service"
# Stop-Service WinRM -PassThru -EV Err -EA "SilentlyContinue"
# Set-Service -Name WinRM -StartupType Disabled -PassThru -EV Err -EA "SilentlyContinue"
#
# Write-BoxstarterMessage "Remove WinRM listeners"
# Invoke-Command -ScriptBlock {
#   winrm delete winrm/config/Listener?Address=*+Transport=HTTP
# }
#
# Write-BoxstarterMessage "Remove WinRM Firewall Entries"
# Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Disabled -EV Err -EA "SilentlyContinue"
#
# # # Set value of LocalAccountTokenFilterPolicy to 0
# # # https://support.microsoft.com/en-us/help/942817/how-to-change-the-remote-uac-localaccounttokenfilterpolicy-registry-se
# # # TODO: Additional Testing needed
# Write-BoxstarterMessage "Restore LocalAccountTokenFilterPolicy Value to 0"
# Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 0 -Type DWord -EV Err -EA "SilentlyContinue"

#--- Restore Temporary Settings ---
Write-BoxstarterMessage "re-Enable UAC"
Enable-UAC
Write-BoxstarterMessage "re-Enable Windows Update"
Enable-MicrosoftUpdate

# No matter the current execution policy, set it to Restricted to lock down machine.
Write-Output "Locking Execution Policy to Restricted..."
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted -Force -EV Err -EA "SilentlyContinue"

Disable-PSRemoting
Write-BoxstarterMessage "Machine is locked down."
