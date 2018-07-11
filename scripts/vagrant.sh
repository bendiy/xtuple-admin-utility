#!/usr/bin/env bash
export TYPE=${1}
export TIMEZONE=${2}
export GITHUB_TOKEN=${3}
export HOST_USERNAME=${4}
export DEPLOYER_NAME=${5}
export DEPLOYER_PASS=${6}

export SCRIPTS_DIR='/vagrant/scripts/xtc'
export CONFIG_DIR='/vagrant/config'

sudo apt-get -q -y update && \
sudo apt-get -q -y install git

source ${SCRIPTS_DIR}/common.sh ${TYPE} ${TIMEZONE} '' ${CONFIG_DIR} ${HOST_USERNAME}
source ${SCRIPTS_DIR}/deployer.sh ${TYPE} ${DEPLOYER_NAME} ${DEPLOYER_PASS}
source ${SCRIPTS_DIR}/nginx-vagrant.sh ${CONFIG_DIR}
source ${SCRIPTS_DIR}/php.sh ${TYPE} ${TIMEZONE} ${DEPLOYER_NAME} ${GITHUB_TOKEN} ${CONFIG_DIR}
source ${SCRIPTS_DIR}/postgresql.sh ${TYPE} ${DEPLOYER_NAME} ${DEPLOYER_PASS} ${CONFIG_DIR}

source ${SCRIPTS_DIR}/ruby.sh
source ${SCRIPTS_DIR}/zsh.sh ${TYPE} ${DEPLOYER_NAME} ${CONFIG_DIR}

sudo apt-get -q -y autoremove && \
date > /home/${DEPLOYER_NAME}/.provisioned
