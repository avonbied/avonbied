#!/bin/sh

# Create Initial Setup
apk update
apk add --no-cache curl wget bash sudo bash-completion git gpg
curl -o /etc/bash/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o /etc/bash/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# Create User
adduser -G wheel -s /bin/bash $1
echo -e "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/admins
echo -e "[boot]\nsystemd=true\n\n[automount]\nenabled=true\nmountFsTab=true\nroot=/mnt/\n\n[interop]\nenabled=true\nappendWindowsPath=true\n\n[user]\ndefault=$1" >> /etc/wsl.conf

# Add PATH for Interop
sed -i 's/\(^export PATH="\)/\1\$PATH:/' /etc/profile

# GPG & GCM Config
git config --system commit.gpgsign true
git config --system tag.gpgSign true
git config --system gpg.program "$(which gpg)"
### GCM Config
git config --system credential.helper '/mnt/c/Program\ Files\ \(x86\)/Git\ Credential\ Manager/git-credential-manager.exe'
# curl -L https://aka.ms/gcm/linux-install-source.sh | sh && git-credential-manager configure
# git config --system credential.helper "$(which git-credential-manager)"
### And Uncomment these lines
# git config --system gpg.program '/mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg.exe'
# git config --global credential.credentialStore gpg

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
sudo -u $1 echo 'export GPG_TTY=$(tty)' "/home/$1/.profile"
