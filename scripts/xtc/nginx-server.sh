#!/bin/bash
export DEPLOYER_NAME=${1}
export DOMAIN=${2}
export DOMAIN_ALIAS=${3}
export HTTP_AUTH_NAME=${4}
export HTTP_AUTH_PASS=${5}
export CONFIG_DIR=${6}

sudo apt-get -q -y install nginx && \
sudo rm /etc/nginx/sites-available/default && \
sudo rm /etc/nginx/sites-enabled/default

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original && \
sudo cp ${CONFIG_DIR}/nginx/nginx.conf /etc/nginx/

sudo mv /etc/nginx/mime.types /etc/nginx/mime.types.original && \
sudo cp ${CONFIG_DIR}/nginx/mime.types /etc/nginx/

sudo mv /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.original && \
sudo cp ${CONFIG_DIR}/nginx/fastcgi_params /etc/nginx/

sudo cp -R ${CONFIG_DIR}/nginx/apps /etc/nginx/
sudo cp -R ${CONFIG_DIR}/nginx/conf.d/* /etc/nginx/conf.d/

export SSL=""
if [ -f ~/${DOMAIN}.crt ] && [ -f ~/${DOMAIN}.key ]
then
    export SSL="ssl"
    sudo mkdir -p /etc/nginx/private && \
    sudo mkdir -p /etc/nginx/certs && \
    sudo mv ~/${DOMAIN}.key /etc/nginx/private/ && \
    sudo mv ~/${DOMAIN}.crt /etc/nginx/certs/
fi

# Set default domain to return 404 for non-setup URLs
sudo cp ${CONFIG_DIR}/nginx/sites-available/default.conf.template /etc/nginx/sites-available/default.http.conf && \
sudo ln -s /etc/nginx/sites-available/default.http.conf /etc/nginx/sites-enabled/default.http.conf

environments=("dev" "stage" "live")
for ENVIRONMENT in "${environments[@]}"
do
    # Set dev and live domain aliases (for development)
    sudo cp ${CONFIG_DIR}/nginx/sites-available/stage.conf.template /etc/nginx/sites-available/${ENVIRONMENT}.http.conf && \
    sudo sed -i "s/{DOMAIN_ALIAS}/${DOMAIN_ALIAS}/g" /etc/nginx/sites-available/${ENVIRONMENT}.http.conf && \
    sudo sed -i "s/{ENVIRONMENT}/${ENVIRONMENT}/g" /etc/nginx/sites-available/${ENVIRONMENT}.http.conf && \
    sudo ln -s /etc/nginx/sites-available/${ENVIRONMENT}.http.conf /etc/nginx/sites-enabled/${ENVIRONMENT}.http.conf

    sudo mkdir -p /var/log/nginx/${ENVIRONMENT} && \
    sudo mkdir -p /opt/xtuple/commerce/${ENVIRONMENT}

    # Set real domain for production usage (with or without SSL)
    if [ ${ENVIRONMENT} = "live" ]
    then
        if [ ${SSL} = "ssl" ]
        then
            sudo cp ${CONFIG_DIR}/nginx/sites-available/https.conf.template /etc/nginx/sites-available/https.conf && \
            sudo sed -i "s/{DOMAIN}/${DOMAIN}/g" /etc/nginx/conf.d/ssl.conf && \
            sudo sed -i "s/{DOMAIN}/${DOMAIN}/g" /etc/nginx/sites-available/https.conf && \
            sudo sed -i "s/{ENVIRONMENT}/${ENVIRONMENT}/g" /etc/nginx/sites-available/https.conf && \
            sudo ln -s /etc/nginx/sites-available/https.conf /etc/nginx/sites-enabled/https.conf
        else
            sudo cp ${CONFIG_DIR}/nginx/sites-available/http.conf.template /etc/nginx/sites-available/http.conf && \
            sudo sed -i "s/{DOMAIN}/${DOMAIN}/g" /etc/nginx/sites-available/http.conf && \
            sudo sed -i "s/{ENVIRONMENT}/${ENVIRONMENT}/g" /etc/nginx/sites-available/http.conf && \
            sudo ln -s /etc/nginx/sites-available/http.conf /etc/nginx/sites-enabled/http.conf
        fi
    fi
done

sudo chown -R ${DEPLOYER_NAME}:${DEPLOYER_NAME} /opt/xtuple/commerce/*

sudo apt-get -q -y install apache2-utils && \
sudo htpasswd -b -c /opt/xtuple/commerce/.htpasswd ${HTTP_AUTH_NAME} ${HTTP_AUTH_PASS}

sudo service nginx restart
