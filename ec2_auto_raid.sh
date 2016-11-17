#!/bin/bash
#
# Inspiration from: https://gist.github.com/joemiller/6049831
#
# This script will attempt to detect any ephemeral drives on an EC2 node and create a RAID-0 stripe
# mounted at /mnt. It should be run early on first boot and can be configured with upstart
#
# 1. Use ec2_auto_raid.conf file for upstart then throw this to /usr/local/bin/ec2_auto_raid then build an AMI
#
# 2. Run instance and include this file
#
## ec2 instance w/ instance-profile + raid
# aws ec2 run-instances \
#  --image-id ami-4654abf16 \
#  --count 1 \
#  --instance-type m3.xlarge \
#  --key-name my-key \
#  --user-data file://scripts/auto_raid.sh \
#  --security-group-ids sg-53a3434 \
#  --subnet-id subnet-acdcf \
#  --iam-instance-profile Name="super-duper-instance-profile" \
#  --region=us-west-2 \
#  --profile profile
#
# REMINDER: The instance needs to be an m3.xlarge or similar which includes 2 extra ephemeral volumes.

# Set metadata url
METADATA_URL_BASE="http://169.254.169.254/2012-01-12"

install_dependencies() {
  # Install required dependencies
  DEBIAN_FRONTEND=noninteractive apt-get install mdadm curl -y
}

detect_drive_schema() {
  # Configure Raid - take into account xvdb or sdb
  root_drive=`df -h | grep -v grep | awk 'NR==4{print $1}'`
  if [ "$root_drive" == "/dev/xvda1" ]; then
    echo "Detected 'xvd' drive naming scheme (root: $root_drive)"
    DRIVE_SCHEME='xvd'
  else
    echo "Detected 'sd' drive naming scheme (root: $root_drive)"
    DRIVE_SCHEME='sd'
  fi
  # figure out how many ephemerals we have by querying the metadata API, and then:
  #  - convert the drive name returned from the API to the hosts DRIVE_SCHEME, if necessary
  #  - verify a matching device is available in /dev/
  drives=""
  ephemeral_count=0
  ephemerals=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/ | grep ephemeral)
  for e in $ephemerals; do
    echo "Probing $e .."
    device_name=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/$e)
    # might have to convert 'sdb' -> 'xvdb'
    device_name=$(echo $device_name | sed "s/sd/$DRIVE_SCHEME/")
    device_path="/dev/$device_name"
    # test that the device actually exists since you can request more ephemeral drives than are available
    # for an instance type and the meta-data API will happily tell you it exists when it really does not.
    if [ -b $device_path ]; then
      echo "Detected ephemeral disk: $device_path"
      drives="$drives $device_path"
      ephemeral_count=$((ephemeral_count + 1 ))
    else
      echo "Ephemeral disk $e, $device_path is not present. skipping"
    fi
  done

  if [ "$ephemeral_count" = 0 ]; then
    echo "No ephemeral disk detected. exiting"
    exit 0
  fi
}

unmount_mnt() {
  # ephemeral0 is typically mounted for us already. umount it here
  umount /mnt
}

zero_drives() {
  # overwrite first few blocks in case there is a filesystem, otherwise mdadm will prompt for input
  for drive in $drives; do
    dd if=/dev/zero of=$drive bs=4096 count=1024
  done
}

create_raid() {
  partprobe
  mdadm --create --verbose /dev/md0 --level=0 -c256 --raid-devices=$ephemeral_count $drives
  echo DEVICE $drives | tee /etc/mdadm.conf
  mdadm --detail --scan | tee -a /etc/mdadm.conf
  blockdev --setra 65536 /dev/md0
  mkfs -t ext4 /dev/md0
  mount -t ext4 -o noatime,nobootwait /dev/md0 /mnt
}

clean_fstab() {
  # Remove xvdb/sdb from fstab
  chmod 777 /etc/fstab
  sed -i "/${DRIVE_SCHEME}b/d" /etc/fstab
}

populate_fstab() {
  # Add mount info to fstab
  echo "/dev/md0 /mnt ext4 noatime,nobootwait 0 0" | tee -a /etc/fstab
}

add_mdadm_conf() {
  # Save our configuration in mdadm.conf in case of reboot
  mdadm --detail --scan >> /etc/mdadm/mdadm.conf
  update-initramfs -u
}

if grep -Fq "md0" /proc/mdstat;
then
  echo "Raid already configured" && exit
else
  echo "Configuring Raid.."
  install_dependencies
  detect_drive_schema
  unmount_mnt
  zero_drives
  create_raid
  clean_fstab
  populate_fstab
  add_mdadm_conf
  echo "Done"
fi
