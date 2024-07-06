#! /bin/bash
# Declare Variables
host_name="hostname" # this is the hostname for the server
time_zone="America/New_York" # This is the timezone for the server
swap_size=  # Size in MB
install_log="/install.log" # this is the location of the install log file
apps_install="" # list the apps to be installed seperated by space

touch $install_log
echo "Bootstrap strarted" >> $apps_install
date >> $install_log

# Update cloud config for hostname preservation
if grep -q '^preserve_hostname: false' /etc/cloud/cloud.cfg; then
    #replace false with true
    sed -i 's/^preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
else
    # Add to the bottom of the file
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
fi
date >> $install_log
echo "Preserve Hostname successful" >> $install_log

# Enable root login and password authentication for SSH (CAUTION: LESS SECURE)
# Consider using key-based authentication instead for improved security.
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
date >> $install_log
echo "ssh config modified" >> $install_log

# Create and configure swap file
dd if=/dev/zero bs=1MiB count=$ssize of=/swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
date >> $install_log
echo "swap file created, size $ssize" >> $install_log

# Backup fstab and add swap entry
cp /etc/fstab /etc/fstab.bk
echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
date >> $install_log
echo "fstab modified" >> $install_log

# Set swappiness and persist in sysctl.conf
sysctl vm.swappiness=10
echo "vm.swappiness = 10" >> /etc/sysctl.conf
date >> $install_log
echo "swappiness changed" >> $install_log

# Set timezone and hostname
timedatectl set-timezone $tzone
hostnamectl set-hostname --static $hname
date >> $install_log
echo "hostname changed set to $hname" >> $install_log

# Add hostname to hosts file (alternative using grep and sed)
sed -i "/^127/s/$/\ $hname/g" /etc/hosts
sed -i "/^ff/s/$/\ $hname/g" /etc/hosts
sed -i "/^:/s/$/\ $hname/g" /etc/hosts
date >> $install_log
echo "hosts file modified, hostname $hname" >> $install_log

yum update -y # update the apps and repository
yum install -y $apps_install # Install the specified apps

echo "Bootstrap Complete" >> $install_log