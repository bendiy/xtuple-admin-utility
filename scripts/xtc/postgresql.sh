#!/bin/bash
export TYPE=${1}
export DEPLOYER_NAME=${2}
export DEPLOYER_PASS=${3}
export CONFIG_DIR=${4}

export DEVELOPMENT_DB_PASS=${5}
export STAGE_DB_PASS=${6}
export PRODUCTION_DB_PASS=${7}

sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
sudo apt-get -q -y update && \
sudo apt-get -q -y install postgresql-9.6

sudo -i -u postgres psql postgres --command="CREATE USER ${DEPLOYER_NAME} PASSWORD '${DEPLOYER_PASS}'"
sudo -i -u postgres psql postgres --command="CREATE USER phpunit PASSWORD 'phpunit'"
sudo -i -u postgres psql postgres --command="CREATE DATABASE phpunit OWNER phpunit"
if [ ${TYPE} = 'server' ]; then
    sudo -i -u postgres psql postgres --command="CREATE USER development PASSWORD '${DEVELOPMENT_DB_PASS}'"
    sudo -i -u postgres psql postgres --command="CREATE DATABASE development OWNER development"

    sudo -i -u postgres psql postgres --command="CREATE USER stage PASSWORD '${STAGE_DB_PASS}'"
    sudo -i -u postgres psql postgres --command="CREATE DATABASE stage OWNER stage"

    sudo -i -u postgres psql postgres --command="CREATE USER production PASSWORD '${PRODUCTION_DB_PASS}'"
    sudo -i -u postgres psql postgres --command="CREATE DATABASE production OWNER production"
fi

sudo cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.original && \
sudo cp ${CONFIG_DIR}/postgres/pg_hba-${TYPE}.conf /etc/postgresql/9.6/main/pg_hba.conf
if [ ${TYPE} = 'server' ]; then
    sudo sed -i "s/{DEPLOYER_NAME}/${DEPLOYER_NAME}/g" /etc/postgresql/9.6/main/pg_hba.conf
fi

sudo service postgresql restart
