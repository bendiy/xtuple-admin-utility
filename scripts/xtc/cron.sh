#!/bin/bash
export CONFIG_DIR=${1}

sudo mkdir -p /var/log/xtuple/cron
(sudo crontab -l 2>/dev/null; sudo cat ${CONFIG_DIR}/cron/drupal.crontab) | sudo crontab -
