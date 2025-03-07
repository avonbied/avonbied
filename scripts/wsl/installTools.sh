#!/bin/sh

sudo apk add --no-cache libstdc++ coreutils

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
echo "export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release" >> .profile
echo "nvm_get_arch() { nvm_echo \"x64-musl\"; }" >> .profile
source .profile

# Az CLI / Ansible
sudo apk add --no-cache jq gcc python3-dev libffi-dev openssl-dev cargo make oniguruma-dev ansible-core
python3 -m venv ~/venv/default
echo ". ~/venv/default/bin/activate" >> ~/.bash/bashrc
. ~/venv/default/bin/activate
pip install --upgrade pip
pip install --no-cache-dir azure-cli ansible-dev-tools

# Hashi Tools
for PRODUCT in {terraform,packer,nomad}
do
	# ALT:
 	# VERSION="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/$PRODUCT | grep -o '"current_version":"[^"]*' | grep -o '[^"]*$')"
	VERSION="$(curl -s https://checkpoint-api.hashicorp.com/v1/check/$PRODUCT | jq -r -M '.current_version')"
	sudo apk add --update --virtual .deps --no-cache gnupg && \
		cd /tmp && \
		wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_linux_amd64.zip && \
		wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS && \
		wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig && \
		wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg.exe --import && \
		gpg.exe --verify ${PRODUCT}_${VERSION}_SHA256SUMS.sig ${PRODUCT}_${VERSION}_SHA256SUMS && \
		grep ${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS | sha256sum -c && \
		unzip /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip -d /tmp && \
		mv /tmp/${PRODUCT} /usr/local/bin/${PRODUCT} && \
		rm -f /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS ${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig && \
	apk del .deps
done
