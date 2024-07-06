#! /bin/bash
# Declare Variables
host_name="hostname" # this is the hostname for the server
time_zone="America/New_York" # This is the timezone for the server
swap_size=  # Size in MB
install_log="/install.log" # this is the location of the install log file
apps_install="" # list the apps to be installed seperated by space

touch $install_log
date >> $install_log
