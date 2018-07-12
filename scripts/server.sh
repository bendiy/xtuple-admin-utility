#!/usr/bin/env bash
#
# Initial script updates packages and ensures there is a minimum set of them
#
# $1 - timezone
# $2 - root user new password
# $3 - github access token
# $4 - deployer password
# $5 - server hostname
# $6 - server alias
# $7 - development DB password
# $8 - stage DB password
# $9 - production DB password
# $10 - HTTP authorization password
#
export TYPE='server'
export TIMEZONE=${1}
export ROOT_PASS=${2}
export GITHUB_TOKEN=${3}

export DEPLOYER_NAME='deployer'
export DEPLOYER_PASS=${4}
export SERVER_NAME=${5}
export SERVER_ALIAS=${6}

export DEVELOPMENT_DB_NAME='development'
export DEVELOPMENT_DB_USER='development'
export DEVELOPMENT_DB_PASS=${7}

export STAGE_DB_NAME='stage'
export STAGE_DB_USER='stage'
export STAGE_DB_PASS=${8}

export PRODUCTION_DB_NAME='production'
export PRODUCTION_DB_USER='production'
export PRODUCTION_DB_PASS=${9}

export HTTP_AUTH_NAME=xtuple
export HTTP_AUTH_PASS=${10}

export SCRIPTS_DIR="${HOME}/xtuple-admin-utility/scripts/xtc"
export CONFIG_DIR="${HOME}/xtuple-admin-utility/config"

apt-get -q -y update && \
apt-get -q -y install git && \
git clone git@github.com:amikheychik/xtuple-admin-utility.git && \
cd xtuple-admin-utility

source ${SCRIPTS_DIR}/common.sh ${TYPE} ${TIMEZONE} ${ROOT_PASS} ${CONFIG_DIR}
source ${SCRIPTS_DIR}/deployer.sh ${TYPE} ${DEPLOYER_NAME} ${DEPLOYER_PASS}
source ${SCRIPTS_DIR}/nginx-server.sh ${DEPLOYER_NAME} ${SERVER_NAME} ${SERVER_ALIAS} ${HTTP_AUTH_NAME} ${HTTP_AUTH_PASS} ${CONFIG_DIR}
source ${SCRIPTS_DIR}/php.sh ${TYPE} ${TIMEZONE} ${DEPLOYER_NAME} ${GITHUB_TOKEN} ${CONFIG_DIR}
source ${SCRIPTS_DIR}/postgresql.sh ${TYPE} ${DEPLOYER_NAME} ${DEPLOYER_PASS} ${CONFIG_DIR} ${DEVELOPMENT_DB_PASS} ${STAGE_DB_PASS} ${PRODUCTION_DB_PASS}

source ${SCRIPTS_DIR}/postfix.sh ${DEPLOYER_NAME} ${SERVER_NAME}
source ${SCRIPTS_DIR}/ruby.sh
source ${SCRIPTS_DIR}/zsh.sh ${TYPE} ${DEPLOYER_NAME} ${CONFIG_DIR}
source ${SCRIPTS_DIR}/cron.sh ${CONFIG_DIR}

# Cleanup
cd && \
rm -rf xdruple-server && \
apt-get -q -y autoremove && \
rm ~/init.sh && \
reboot
