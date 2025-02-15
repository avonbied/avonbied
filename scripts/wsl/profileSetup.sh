# Create Initial Setup
apk update
apk add --no-cache curl wget bash sudo gnupg bash-completion git
curl -o /etc/bash/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o /etc/bash/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[boot]\nsystemd=true\n\n[automount]\nenabled=true\nmountFsTab=true\nroot=/mnt/\n\n[interop]\nenabled=true\nappendWindowsPath=true\n\n[user]\ndefault=$1" >> /etc/wsl.conf

# Create Bash Profile
sudo -u $1 mkdir ~/.bash

# .bash_profile
bash_profile="if [ -f ~/.profile ]; then\n\tsource ~/.profile\nfi\n\nif [ -f ~/.bash/bashrc ]; then\n\tsource ~/.bash/bashrc\nfi"
sudo -u $1 echo -e "$bash_profile" >> "/home/$1/.bash_profile"

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
sudo -u $1 touch "/home/$1/.profile"
