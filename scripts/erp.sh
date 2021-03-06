#!/usr/bin/env bash
DATABASE=xdruple_1_1_x
DATABASE_BACKUP=/vagrant/var/backups/xdruple.backup
DATABASE_ENCRYPTION=/vagrant/var/backups/xdruple.encryption.txt
DATABASE_PASSWORD='admin'
APPLICATION='http://flywheel.xd/'

sudo cp ${DATABASE_ENCRYPTION} /etc/xtuple/${DATABASE}/private/encryption.txt

sudo systemctl stop xtuple-${DATABASE}

sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DATABASE}"
sudo -u postgres psql -c "CREATE DATABASE ${DATABASE} OWNER = 'admin'"
sudo -u postgres psql -At -d ${DATABASE} <<EOSCRIPT
  CREATE SCHEMA IF NOT EXISTS xt;
  GRANT ALL ON SCHEMA xt TO GROUP xtrole;
  CREATE EXTENSION IF NOT EXISTS plv8;
  CREATE OR REPLACE FUNCTION xt.js_init(debug BOOLEAN DEFAULT false, initialize BOOLEAN DEFAULT false)
  RETURNS VOID AS 'BEGIN RETURN; END;' LANGUAGE plpgsql;
EOSCRIPT
sudo -u postgres pg_restore --dbname ${DATABASE} ${DATABASE_BACKUP}

sudo -u postgres psql -d ${DATABASE} -c "DELETE FROM xt.sessionstore;"
sudo -u postgres psql -d ${DATABASE} -c "UPDATE xt.oa2client SET oa2client_org = current_database();"
sudo -u postgres psql -d ${DATABASE} -c "DELETE FROM xt.js WHERE js_namespace = 'XDRUPLE' AND js_context = 'xdruple';"
sudo -u postgres psql -d ${DATABASE} -c "DELETE FROM xt.js WHERE js_namespace = 'OAUTH2' AND js_context = 'xtuple';"
sudo -u postgres psql -d ${DATABASE} -c "DROP VIEW xdruple.oauth_2_token;"
sudo -u postgres psql -d ${DATABASE} -c "DROP VIEW xdruple.oauth_2_client;"

CONFIG_DIR=/etc/xtuple/${DATABASE}
XTUPLE_REPOS_DIR=/opt/xtuple/node/${DATABASE}

pushd ${XTUPLE_REPOS_DIR}
    pushd ./xtuple
        sudo rm -rf node_modules
        git submodule update --init
        npm install
    popd
    pushd ./private-extensions
        sudo rm -rf node_modules
        git submodule update --init
        npm install
    popd
    pushd ./payment-gateways
        make clean
        make
    popd
    pushd ./xdruple-extension
        make clean
        make
    popd
    pushd ./xtuple
      ./scripts/build_app.js \
        -c ${CONFIG_DIR}/config.js \
        -d ${DATABASE}
    popd
    pushd ./xdruple-extension
      ./scripts/keygen.js \
        -c ${CONFIG_DIR}/config.js \
        -d ${DATABASE} \
        -a ${APPLICATION} \
        -i ${DATABASE} \
        -p /var/xtuple/keys/${DATABASE}.p12
    popd
popd

sudo systemctl start xtuple-${DATABASE}
