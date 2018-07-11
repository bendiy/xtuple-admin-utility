#!/bin/bash
#
# Deployment user setup
#
export TYPE=${1}
export DEPLOYER_NAME=${2}
export DEPLOYER_PASS=${3}

if [ ${TYPE} = 'server' ]; then
    sudo useradd -b /home -s /bin/zsh -m -U ${DEPLOYER_NAME}
fi
echo ${DEPLOYER_NAME}:${DEPLOYER_PASS} | sudo chpasswd

sudo mkdir -p /home/${DEPLOYER_NAME}/.ssh && \
sudo ssh-keyscan -H github.com >> ~/.ssh/known_hosts && \
sudo ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts && \
sudo cp ~/.ssh/known_hosts /home/${DEPLOYER_NAME}/.ssh/

if [ ${TYPE} = 'server' ] && [ -f ~/deployer_rsa.pub ] && [ -f ~/deployer_rsa ]; then
    sudo cat ~/deployer_rsa.pub >> /home/${DEPLOYER_NAME}/.ssh/authorized_keys && \
    sudo mv ~/deployer_rsa /home/${DEPLOYER_NAME}/.ssh/id_rsa && \
    sudo mv ~/deployer_rsa.pub /home/${DEPLOYER_NAME}/.ssh/id_rsa.pub
fi

sudo chown -R ${DEPLOYER_NAME}:${DEPLOYER_NAME} /home/${DEPLOYER_NAME}/.ssh

if [ ${TYPE} = 'server' ]; then
    # Allow deployment user to sudo as www-data with no password
    sudo printf "%%${DEPLOYER_NAME} ALL=(www-data) NOPASSWD: ALL\n" > /etc/sudoers.d/${DEPLOYER_NAME} && \
    sudo chmod 440 /etc/sudoers.d/${DEPLOYER_NAME}
fi
