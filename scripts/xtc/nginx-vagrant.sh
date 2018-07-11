#!/bin/bash
export CONFIG_DIR=${1}

sudo apt-get -q -y install nginx && \
sudo rm /etc/nginx/sites-available/default && \
sudo rm /etc/nginx/sites-enabled/default && \
sudo rm -rf /var/www

sudo cp -R ${CONFIG_DIR}/nginx/sites-available/xdruple.conf /etc/nginx/sites-available/ && \
sudo ln -s /etc/nginx/sites-available/xdruple.conf /etc/nginx/sites-enabled/

sudo service nginx restart
