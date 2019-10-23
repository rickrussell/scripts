## Links
## https://blogs.technet.microsoft.com/bruce_adamczak/2013/01/18/windows-2012-core-survival-guide-managing-basic-ipv4-configuration-information
## https://social.technet.microsoft.com/Forums/ie/en-US/083f800b-cf47-4c4b-8753-a7f67885a2b8/powershell-addprinterdriver-for-a-driver-that-is-not-on-the-remote-machine?forum=ITCG
## https://4sysops.com/archives/install-and-manage-a-print-server-in-server-core/
## https://4sysops.com/archives/server-core-remote-management-part-1/
## http://www.informit.com/articles/article.aspx?p=1947698&seqNum=5

## Server 2012R2 Core Print Server

## Configure IP
New-NetIPAddress -interfaceindex 12 -IPAddress 10.66.6.20 -Prefixlength 24 -defaultgateway 10.66.6.1

## Join to domain
Add-computer -DomainName noneck.io -Credential "DARKLORD\PDQDeployService" -Restart

## Add mapped Drive
net use f: \\hekate\share /persistent:yes /user:"DARKLORD\hekate"
Start-Sleep 10

## make driver directories
mkdir C:\Drivers
mkdir C:\Drivers\KX_Universal
mkdir C:\Drivers\KXv4
mkdir C:\Drivers\hp_4000

## Install Drivers
## Copy over Kyocera Universal drivers
robocopy.exe \\hekate\share\Software\Kyocera\Drivers\KX_Universal_v3.3_signed\ C:\Drivers\KX_Universal /E /IS
## Add latest Kyocera Server 2012R2 PCL Drivers
robocopy.exe \\hekate\share\Software\Kyocera\Drivers\KXv4_v521303_signed\ C:\Drivers\KXv4 /E /IS
## Add HP Drivers
robocopy.exe \\hekate\share\Software\HP\upcl6 C:\Drivers\hp_4000 /E /IS

## Install Kyocera PCL6 Drivers
Invoke-Command {pnputil.exe -a "C:\Drivers\KXv4\KXv4_v521303_signed\KXv4Driver\en\PrnDrv\PCL Driver\64bit\win8 and newer\prnkycl1.inf" }
Add-PrinterDriver -Name "Kyocera ECOSYS M3540idn v4 KX (PCL6)"
Start-Sleep 10
Add-PrinterDriver -Name "Kyocera TASKalfa 3501i v4 KX (PCL6)"
Start-Sleep 10
Add-PrinterDriver -Name "Kyocera TASKalfa 3551ci v4 KX (PCL6)"
Start-Sleep 10
Add-PrinterDriver -Name "Kyocera TASKalfa 5551ci v4 KX (PCL6)"
Start-Sleep 10

## Install HP DesignJet drivers
Invoke-Command {pnputil.exe -a "C:\Drivers\HP_4000\hpcu230u.inf" }
Add-PrinterDriver -Name "HP Universal Printing PCL 6"
Start-Sleep 10

## Add Printer Ports (for attaching printers to)
## Chestnut Storekeeper
Add-PrinterPort -Name "10.66.6.81_STOREKEEPER" -PrinterHostAddress "10.66.6.81"
Start-Sleep 2
## noneck Hallway
Add-PrinterPort -Name "10.66.6.82_noneck_HALLWAY" -PrinterHostAddress "10.66.6.82"
Start-Sleep 2
## Service Center
Add-PrinterPort -Name "10.66.6.84_SERVICE_CENTER" -PrinterHostAddress "10.66.6.84"
Start-Sleep 2
## noneck Front Office
Add-PrinterPort -Name "10.66.6.83_noneck_Front_Office" -PrinterHostAddress "10.66.6.83"
Start-Sleep 2
## Meter Tech Printer
Add-PrinterPort -Name "10.66.6.124_LASERJET" -PrinterHostAddress "10.66.6.124"
Start-Sleep 2

## Add Printers
Add-Printer -Name Kyocera_3540_Storekeeper -DriverName "Kyocera ECOSYS M3540idn v4 KX (PCL6)" -PortName 10.66.6.81_STOREKEEPER -Shared -ShareName "Kyocera Service Center Storekeeper" –Published
Start-Sleep 10
Add-Printer -Name Kyocera_5551_noneck_Hallway -DriverName "Kyocera TASKalfa 5551ci v4 KX (PCL6)" -PortName 10.66.6.82_noneck_HALLWAY -Shared -ShareName "Kyocera noneck Hallway" –Published
Start-Sleep 10
Add-Printer -Name Kyocera_5551_Service_Center -DriverName "Kyocera TASKalfa 5551ci v4 KX (PCL6)" -PortName 10.66.6.84_SERVICE_CENTER -Shared -ShareName "Kyocera Service Center" –Published
Start-Sleep 10
Add-Printer -Name Kyocera_3501_noneck_Front -DriverName "Kyocera TASKalfa 3501i v4 KX (PCL6)" -PortName 10.66.6.83_noneck_Front_Office -Shared -ShareName "Kyocera noneck Front Office" –Published
Start-Sleep 10
Add-Printer -Name HP_LaserJet_4000 -DriverName "HP Universal Printing PCL 6" -PortName 10.66.6.124_LASERJET -Shared -ShareName "HP LaserJet 4000 (Production)" –Published
Start-Sleep 10
