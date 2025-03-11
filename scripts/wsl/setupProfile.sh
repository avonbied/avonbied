#!/bin/sh

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[user]\ndefault=$1" >> /etc/wsl.conf

# Create Bash Profile
mkdir "/home/$1/.bash"

# .profile
echo -e "if [ -f ~/.bash/bashrc ]; then
	source ~/.bash/bashrc
fi
# export GPG_TTY=\$(tty)" >> "/home/$1/.profile"

# .bash/bashrc
echo -e "source /etc/bash/git-completion.bash
source /etc/bash/git-prompt.sh
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;32m\]\$(__git_ps1)\[\033[01;34m\] \\\$\[\033[34m\] '" >> "/home/$1/.bash/bashrc"

chown -R $1 "/home/$1"