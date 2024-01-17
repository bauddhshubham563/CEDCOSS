#!/bin/bash

sudo apt-get update
sudo apt install ssh -y
sudo chage -M 90 -W 7 cedcoss
sudo chmod  -R 400 /media

# Check if the script is being run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Replace 'newuser' with your desired username
newuser=Administrator
password=Ced@Cedco##
# Add the new user with home directory and /bin/bash shell
sudo useradd -m -s /bin/bash $newuser
sudo usermod -aG sudo $newuser
# Set the password for the new user (optional)
# Replace 'password' with your desired password
 echo "$newuser:$password" | chpasswd
sudo apt install figlet -y
figlet "        DONE . . . ! ! !         "
rm $0