#!/bin/bash
# change the variables below
hname="hostname"
tzone="America/New_York"
ssize="1024"
instlog="/install.log"
# define all the apps you want to install seperated by space do not add apache2 as the name is different for centos
apps="curl git wget nginx php mysql-server"
# Create Log file
touch $instlog
date >> $instlog
echo "Bootstrap started" >> $instlog

# Update cloud config for hostname preservation
if grep -q '^preserve_hostname: false' /etc/cloud/cloud.cfg; then
    #replace false with true
    sed -i 's/^preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
else
    # Add to the bottom of the file
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
fi
date >> $instlog
echo "Preserve Hostname successful" >> $instlog

# Enable root login and password authentication for SSH (CAUTION: LESS SECURE)
# Consider using key-based authentication instead for improved security.
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
date >> $instlog
echo "ssh config modified" >> $instlog

# Create and configure swap file
dd if=/dev/zero bs=1MiB count=$ssize of=/swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
date >> $instlog
echo "swap file created, size $ssize" >> $instlog

# Backup fstab and add swap entry
cp /etc/fstab /etc/fstab.bk
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
date >> $instlog
echo "fstab modified" >> $instlog

# Set swappiness and persist in sysctl.conf
sysctl vm.swappiness=10
echo "vm.swappiness = 10" >> /etc/sysctl.conf
date >> $instlog
echo "swappiness changed" >> $instlog

# Set timezone and hostname
timedatectl set-timezone $tzone
hostnamectl set-hostname --static $hname
date >> $instlog
echo "hostname changed set to $hname" >> $instlog

# Add hostname to hosts file (alternative using grep and sed)
sed -i "/^127/s/$/\ $hname/g" /etc/hosts
sed -i "/^ff/s/$/\ $hname/g" /etc/hosts
sed -i "/^:/s/$/\ $hname/g" /etc/hosts
date >> $instlog
echo "hosts file modified, hostname $hname" >> $instlog

# Update Ubuntu Servers
export DEBIAN_FRONTEND=noninteractive
apt-get update -qy
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -qy
date >> $instlog
echo "server updated" >> $instlog

# Install Apps
export DEBIAN_FRONTEND=noninteractive
apt-get update -qy
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install $apps -qy
date >> $instlog
echo "installed $apps" >> $instlog

date >> $instlog
echo "Boot strap complete" >> $instlog

reboot
instlog="/install.log"
echo "reboot complete" >> $instlog
