#!/bin/sh

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[user]\ndefault=$1" >> /etc/wsl.conf

# Create Config
curl -o- https://raw.githubusercontent.com/avonbied/avonbied/refs/heads/main/scripts/unix/profile-config.sh | sh

# .profile
curl -o "/home/$1/.profile" https://raw.githubusercontent.com/avonbied/avonbied/refs/heads/main/scripts/wsl/utils/profile

# .bashrc
curl -o "/home/$1/.bashrc" https://raw.githubusercontent.com/avonbied/avonbied/refs/heads/main/scripts/wsl/utils/bashrc