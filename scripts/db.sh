#!/usr/bin/env bash
DATABASE_VERSION=4.11.3
DATABASE_TYPE=demo
DATABASE_BACKUP=/tmp/"${DATABASE_VERSION}"-"${DATABASE_TYPE}".backup
DATABASE='erp'
DATABASE_PASSWORD='admin'

wget --output-document=${DATABASE_BACKUP} \
  "http://files.xtuple.org/${DATABASE_VERSION}/${DATABASE_TYPE}.backup"
wget --output-document=${DATABASE_BACKUP}.md5sum \
  "http://files.xtuple.org/${DATABASE_VERSION}/${DATABASE_TYPE}.backup.md5sum"

sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DATABASE}"
sudo -u postgres psql -c "CREATE DATABASE ${DATABASE} OWNER = 'admin'";
sudo -u postgres psql -At -d ${DATABASE} <<EOSCRIPT
  CREATE SCHEMA IF NOT EXISTS xt;
  GRANT ALL ON SCHEMA xt TO GROUP xtrole;
  CREATE EXTENSION IF NOT EXISTS plv8;
  CREATE OR REPLACE FUNCTION xt.js_init(debug BOOLEAN DEFAULT false, initialize BOOLEAN DEFAULT false)
  RETURNS VOID AS 'BEGIN RETURN; END;' LANGUAGE plpgsql;
EOSCRIPT
sudo -u postgres pg_restore --dbname "${DATABASE}" ${DATABASE_BACKUP}
