#!/bin/sh

# Create Initial Setup
apk update
apk add --no-cache curl wget bash sudo bash-completion git
curl -o /etc/bash/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o /etc/bash/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

echo -e "[boot]\nsystemd=false\n\n[automount]\nenabled=true\nmountFsTab=true\nroot=/mnt/\n\n[interop]\nenabled=true\nappendWindowsPath=true\n\n" >> /etc/wsl.conf
# Add PATH for Interop
sed -i 's/\(^export PATH="\)/\1\$PATH:/' /etc/profile

curl -o /usr/local/bin/pam_systemd_setup https://raw.githubusercontent.com/avonbied/avonbied/refs/heads/main/scripts/wsl/utils/pam_systemd_setup
echo -e "ALL ALL=(root) NOPASSWD: /usr/local/bin/pam_systemd_setup" >> /etc/sudoers.d/admins
echo -e "sudo /usr/local/bin/pam_systemd_setup.sh \$USER" >> /etc/profile.d/pam_system.sh

# GPG & GCM Config (Interop)
git config --system commit.gpgsign true
git config --system tag.gpgSign true
git config --system gpg.program '/mnt/c/Program Files (x86)/GnuPG/bin/gpg.exe'
git config --system credential.helper '/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe'

# GPG & GCM Config (Local)
# apk add gpg && git config --system gpg.program "$(which gpg)"
# git config --system credential.credentialStore gpg
# curl -L https://aka.ms/gcm/linux-install-source.sh | sh && git-credential-manager configure
# git config --system credential.helper "$(which git-credential-manager)"