#!/bin/sh

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[user]\ndefault=$1" >> /etc/wsl.conf

# Create Config
curl -o- https://raw.githubusercontent.com/avonbied/avonbied/refs/heads/main/scripts/unix/profile-config.sh | sh

# .profile
echo -e "if [ -L ~/.bashrc ]; then
	source ~/.bashrc
fi
# export GPG_TTY=\$(tty)" >> "/home/$1/.profile"

# .bashrc
echo -e "source /etc/bash/git-completion.bash
source /etc/bash/git-prompt.sh
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;32m\]\$(__git_ps1)\[\033[01;34m\] \\\$\[\033[34m\] '" >> "/home/$1/.bashrc"

chown -R $1 "/home/$1"

mkdir -p "/run/user/$(id -u $1)"
chown -R $1 "/run/user/$(id -u $1)"