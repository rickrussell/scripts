#optional firewall allows
netsh advfirewall firewall add rule name="Microsoft iSCSI Software Target Service-TCP-3260" dir=in action=allow protocol=TCP localport=3260
netsh advfirewall firewall add rule name="Microsoft iSCSI Software Target Service-TCP-135" dir=in action=allow protocol=TCP localport=135
netsh advfirewall firewall add rule name="Microsoft iSCSI Software Target Service-UDP-138" dir=in action=allow protocol=UDP localport=138
netsh advfirewall firewall add rule name="Microsoft iSCSI Software Target Service" dir=in action=allow program="%SystemRoot%\System32\WinTarget.exe" enable=yes
netsh advfirewall firewall add rule name="Microsoft iSCSI Software Target Service Status Proxy" dir=in action=allow program="%SystemRoot%\System32\WTStatusProxy.exe" enable=yes

# enable and start iscsi service
set-service -name msiscsi -startuptype automatic
start-service msiscsi
Install-WindowsFeature -name Multipath-IO

# Connect ISCSI Target Portal

# w/ Discovery CHAP
New-IscsiTargetPortal –AuthenticationType ONEWAYCHAP –ChapUserName <name> -ChapSecret <Secret> -TargetPortalAddress 10.66.6.32 -InitiatorPortalAddress 192.168.25.20 #-InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"

# w/out DIscovery CHAP
New-IscsiTargetPortal -TargetPortalAddress 10.66.6.32 -InitiatorPortalAddress 192.168.25.20 -InitiatorInstanceName "ROOT\ISCSIPRT\0000_"

# Connect Discovered Target(endpoint)
$target = Get-IscsiTarget
Connect-iScsitarget -NodeAddress $target.NodeAddress[1] -IsPersistent $true –IsMultipathEnabled $true –AuthenticationType ONEWAYCHAP –ChapUserName <name> -ChapSecret <Secret> –InitiatorPortalAddress 10.66.6.20

# Initialize and Partition Disks

Set-Disk 1 -isOffline $false
Set-Disk 1 -isReadOnly $false
$Disk = Get-Disk 1
$Disk | Initialize-Disk -PartitionStyle GPT

New-Partition $Disk.Number -UseMaximumSize -DriveLetter U
Get-PartitionSupportedSize -DriveLetter U | Format-List
Format-Volume -DriveLetter U -FileSystem NTFS -NewFileSystemLabel SAN-Users -Confirm:$false
New-Item -ItemType Directory -Path "U:\Users"
New-SmbShare -Name Users -Description "Shared User Directories" -Path U:\Users
Grant-SmbShareAccess -Name Users -AccountName "noneck.io\Domain Admins" -AccessRight Full

# If you add another ISCSI share on the Buffalo after you've run the above, then you'll
# have to update the tartget list:
Update-iscsiTaget

$target = Get-IscsiTarget
Connect-iScsitarget -NodeAddress $target.NodeAddress[2] -IsPersistent $true –IsMultipathEnabled $true –AuthenticationType ONEWAYCHAP –ChapUserName <name> -ChapSecret <Secret> –InitiatorPortalAddress 10.66.6.20

Set-Disk 2 -isOffline $false
Set-Disk 2 -isReadOnly $false
$Disk = Get-Disk 2
$Disk | Initialize-Disk -PartitionStyle GPT
New-Partition $Disk.Number -UseMaximumSize -DriveLetter S
Get-PartitionSupportedSize -DriveLetter S | Format-List
Format-Volume -DriveLetter S -FileSystem NTFS -NewFileSystemLabel SAN-Shared -Confirm:$false
New-Item -ItemType Directory -Path "S:\Shared"
New-SmbShare -Name Shared -Description "Shared Fileshare" -Path S:\Shared
Grant-SmbShareAccess -Name Shared -AccountName "noneck.io\Domain Admins" -AccessRight Full -Confirm:$false

# Resources
# http://woshub.com/disks-partitions-management-powershell/
# https://stackoverflow.com/questions/32192483/assign-a-mount-point-folder-path-to-a-drive-using-powershell
# https://winpoin.com/cara-format-hard-drive-dengan-powershell-di-windows-10/
# https://www.tenforums.com/tutorials/96684-delete-volume-partition-windows-10-a.html
# https://pureinfotech.com/format-hard-drive-powershell-windows-10/
# https://www.thomasmaurer.ch/2012/04/replace-diskpart-with-windows-powershell-basic-storage-cmdlets/
# https://stackoverflow.com/questions/47929179/powershell-new-partition-complains-about-driveletter-argument
# https://rakhesh.com/windows/notes-on-iscsi-and-server-core-2012/
# https://chinnychukwudozie.com/2013/11/11/configuring-multipath-io-with-multiple-iscsi-connections-using-powershell/
# https://blogs.technet.microsoft.com/keithmayer/2013/03/12/step-by-step-speaking-iscsi-with-windows-server-2012-and-hyper-v-become-a-virtualization-expert-in-20-days-part-7-of-20/
# https://blogs.msdn.microsoft.com/san/2012/07/31/managing-iscsi-initiator-connections-with-windows-powershell-on-windows-server-2012/
