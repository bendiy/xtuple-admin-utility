#!/bin/bash
#
# server-keygen.sh
# Generates keypairs for root and deploy users to be used on a single server.
#
# Parameters:
# $1 - email
# $2 - site URL (e.g. prodiem.xtuple.org)
# $3 - site shorthand (e.g. prodiem)
# $4 - root key passphrase
#
export EMAIL=${1}
export URL=${2}
export SHORTHAND=${3}
export ROOTPASS=${4}
export DEPLOYPASS=''

mkdir -p ~/.ssh/${URL} && cd ~/.ssh/${URL}
ssh-keygen -q -t rsa -b 4096 -C ${EMAIL} -f ./${SHORTHAND}_root_rsa -N ${ROOTPASS}
ssh-keygen -q -t rsa -b 4096 -C ${EMAIL} -f ./${SHORTHAND}_deployer_rsa -N "${DEPLOYPASS}"
