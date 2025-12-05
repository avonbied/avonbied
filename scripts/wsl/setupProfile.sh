#!/bin/sh

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[user]\ndefault=$1" >> /etc/wsl.conf

# Create Bash Profile
sudo -u $1 mkdir ~/.bash

# .profile
profile=$(cat<<EOF
if [ -f ~/.bash/bashrc ]; then
	source ~/.bash/bashrc
fi
# export GPG_TTY=$(tty)
EOF
)
sudo -u $1 echo -e "$profile" >> "/home/$1/.profile"

# .bash/bashrc
bashrc=$(cat<<EOF
source /etc/bash/git-completion.bash
source /etc/bash/git-prompt.sh

if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;32m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[34m\] '
EOF
)
sudo -u $1 echo -e "$bashrc" >> "/home/$1/.bash/bashrc"
