#!/usr/bin/env bash
DATABASE='erp'
DATABASE_PASSWORD='admin'
XTUPLE_REPOS_DIR=/opt/xtuple/node
XTUPLE_DIR=${XTUPLE_REPOS_DIR}/xtuple
CONFIG_DIR="/etc/xtuple/${DATABASE}"
PORT=8443
export PAYMENT_GATEWAYS_SETTINGS_KEY=''
export OAUTH2_SERVER_PORT_1=${PORT}
export OAUTH2_SERVER_PORT_2=${PORT}

cd ${XTUPLE_REPOS_DIR}/xtuple
npm install
cd ${XTUPLE_REPOS_DIR}/xtuple/test/lib
cat sample_login_data.js \
  | sed \
      -e "s/pwd: 'admin'/pwd: '${DATABASE_PASSWORD}'/" \
      -e "s/org: 'dev'/org: '${DATABASE}'/" \
      -e "s/8443/${PORT}/" \
  > login_data.js

cd ${XTUPLE_REPOS_DIR}/private-extensions
npm install
cd ${XTUPLE_REPOS_DIR}/private-extensions/test/lib
cat sample_login_data.js \
  | sed \
      -e "s/pwd: 'admin'/pwd: '${DATABASE_PASSWORD}'/" \
      -e "s/org: 'dev'/org: '${DATABASE}'/" \
      -e "s/8443/${PORT}/" \
  > login_data.js
cd ${XTUPLE_REPOS_DIR}/private-extensions
npm run-script test-build

cd ${XTUPLE_REPOS_DIR}/payment-gateways
make

cd ${XTUPLE_REPOS_DIR}/xdruple-extension
make

pushd ${XTUPLE_REPOS_DIR}/xtuple
  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE}

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../private-extensions/source/commercialcore

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../private-extensions/source/inventory \
    -f

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../private-extensions/source/manufacturing \
    -f

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../private-extensions/source/distribution \
    -f

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../enhanced-pricing

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../nodejsshim

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../payment-gateways

  ./scripts/build_app.js \
    -c ${CONFIG_DIR}/config.js \
    -d ${DATABASE} \
    -e ../xdruple-extension
popd

cd ${XTUPLE_REPOS_DIR}/xdruple-extension/test/lib
cat sample_login_data.js \
  | sed \
      -e "s/pwd: 'admin'/pwd: '${DATABASE_PASSWORD}'/" \
      -e "s/org: 'dev'/org: '${DATABASE}'/" \
      -e "s/8443/${PORT}/" \
  > login_data.js
cd ${XTUPLE_REPOS_DIR}/xdruple-extension
npm run test
