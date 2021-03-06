#!/usr/bin/env bash
#
# server-keygen.sh
# Generates keypairs for root and deploy users to be used on a single server.
#
# Parameters:
# $1 - email
# $2 - domain (e.g. example.com)
# $3 - root key passphrase
#

function xtau_generate_keypair_rsa() {
    EMAIL=${1}
    DOMAIN=${2}
    KEYNAME=${3}
    PASSPHRASE=${4}
    DIRECTORY=${HOME}/.ssh/xtau/${DOMAIN}
    mkdir -p ${DIRECTORY} \
    && ssh-keygen -q -t rsa -b 4096 \
        -C "${DOMAIN} ${KEYNAME}_rsa generated by xTAU by ${EMAIL}" \
        -f ${DIRECTORY}/${KEYNAME}_rsa \
        -N "${PASSPHRASE}"
}

xtau_generate_keypair_rsa ${1} ${2} root ${3}
xtau_generate_keypair_rsa ${1} ${2} deployer ''
