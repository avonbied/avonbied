#!/bin/sh

sudo apk add --no-cache libstdc++ coreutils

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
echo "export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release" >> .profile
echo "nvm_get_arch() { nvm_echo \"x64-musl\"; }" >> .profile
source .profile
