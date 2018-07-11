#!/bin/bash
export TYPE=${1}
export DEPLOYER_NAME=${2}
export CONFIG_DIR=${3}

sudo apt-get -q -y install \
    zsh

sudo su -c 'curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh'
cd /home/${DEPLOYER_NAME} && sudo su -c "curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh" ${DEPLOYER_NAME}
sudo chsh -s /usr/bin/zsh ${DEPLOYER_NAME}

sudo cp /home/${DEPLOYER_NAME}/.zshrc /home/${DEPLOYER_NAME}/.zshrc.original && \
sudo cp ${CONFIG_DIR}/zsh/zshrc.sh /home/${DEPLOYER_NAME}/.zshrc && \
sudo sed -i "s/{DEPLOYER_NAME}/${DEPLOYER_NAME}/g" /home/${DEPLOYER_NAME}/.zshrc
