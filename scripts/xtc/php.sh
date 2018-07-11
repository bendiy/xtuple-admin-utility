#!/bin/bash
export TYPE=${1}
export TIMEZONE=${2}
export DEPLOYER_NAME=${3}
export GITHUB_TOKEN=${4}
export CONFIG_DIR=${5}

export PCRE_BACKTRACK_LIMIT=10000000
export MAX_EXECUTION_TIME=60
if [ ${TYPE} = 'vagrant' ]; then
    export MAX_EXECUTION_TIME=600
fi

sudo add-apt-repository -y ppa:ondrej/php && \
sudo apt-get -q -y update && \
sudo apt-get -q -y upgrade && \
sudo apt-get -q -y install \
  php-common \
  php7.1-common \
  php7.1-json \
  php7.1-opcache \
  php7.1-readline \
  php7.1-fpm \
  php7.1 \
  php7.1-xml \
  php7.1-dev \
  php7.1-gd \
  php7.1-pgsql \
  php7.1-curl \
  php7.1-intl \
  php7.1-mcrypt \
  php7.1-mbstring \
  php7.1-soap \
  php7.1-zip

if [ ${TYPE} = 'vagrant' ]; then
    sudo apt-get -q -y install \
        php-xdebug && \
  sudo cp /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/mods-available/xdebug.ini.original && \
  sudo cp ${CONFIG_DIR}/php/mods/xdebug.ini /etc/php/7.1/mods-available/xdebug.ini
fi

sudo cp /etc/php/7.1/fpm/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf.original && \
sudo cp ${CONFIG_DIR}/php/fpm/php-fpm.conf.ini /etc/php/7.1/fpm/php-fpm.conf

sudo cp /etc/php/7.1/fpm/pool.d/www.conf /etc/php/7.1/fpm/pool.d/www.conf.original && \
sudo cp ${CONFIG_DIR}/php/fpm/www.conf.ini /etc/php/7.1/fpm/pool.d/www.conf

export ESCAPED_TIMEZONE=$(echo ${TIMEZONE} | sed -e 's/[]\/$*.^|[]/\\&/g')
sudo cp /etc/php/7.1/fpm/php.ini /etc/php/7.1/fpm/php.ini.original && \
sudo cp ${CONFIG_DIR}/php/fpm/php.ini /etc/php/7.1/fpm/php.ini && \
sudo sed -i "s/{TIMEZONE}/${ESCAPED_TIMEZONE}/g" /etc/php/7.1/fpm/php.ini && \
sudo sed -i "s/{MAX_EXECUTION_TIME}/${MAX_EXECUTION_TIME}/g" /etc/php/7.1/fpm/php.ini && \
sudo sed -i "s/{PCRE_BACKTRACK_LIMIT}/${PCRE_BACKTRACK_LIMIT}/g" /etc/php/7.1/fpm/php.ini

sudo cp /etc/php/7.1/cli/php.ini /etc/php/7.1/cli/php.ini.original && \
sudo cp ${CONFIG_DIR}/php/cli/php.ini /etc/php/7.1/cli/php.ini && \
sudo sed -i "s/{TIMEZONE}/${ESCAPED_TIMEZONE}/g" /etc/php/7.1/cli/php.ini && \
sudo sed -i "s/{PCRE_BACKTRACK_LIMIT}/${PCRE_BACKTRACK_LIMIT}/g" /etc/php/7.1/cli/php.ini

# Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');" && \
sudo mv composer.phar /usr/local/bin/composer && \
sudo mkdir -p /home/${DEPLOYER_NAME}/.composer && \
sudo cp ${CONFIG_DIR}/php/composer/config-${TYPE}.json /home/${DEPLOYER_NAME}/.composer/config.json && \
sudo sed -i "s/{GITHUB_TOKEN}/${GITHUB_TOKEN}/g" /home/${DEPLOYER_NAME}/.composer/config.json && \
sudo chown -R ${DEPLOYER_NAME}:${DEPLOYER_NAME} /home/${DEPLOYER_NAME}/.composer

# PHPUnit (v6.x)
wget https://phar.phpunit.de/phpunit.phar && \
chmod +x phpunit.phar && \
sudo mv phpunit.phar /usr/local/bin/phpunit

# Phing (v2.x)
wget https://www.phing.info/get/phing-latest.phar && \
chmod +x phing-latest.phar && \
sudo mv phing-latest.phar /usr/local/bin/phing

# Phing dependencies
sudo pear install VersionControl_Git-0.5.0

# PHP CodeSniffer
wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
chmod +x phpcs.phar && \
sudo mv phpcs.phar /usr/local/bin/phpcs

# PHP Code Beautifier
wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && \
chmod +x phpcbf.phar && \
sudo mv phpcbf.phar /usr/local/bin/phpcbf

# PHP Mess Detector
wget -c http://static.phpmd.org/php/latest/phpmd.phar && \
chmod +x phpmd.phar && \
sudo mv phpmd.phar /usr/local/bin/phpmd

# PDepend (v2.x)
wget http://static.pdepend.org/php/latest/pdepend.phar && \
chmod +x pdepend.phar && \
sudo mv pdepend.phar /usr/local/bin/pdepend

# Couscous (User documentation generation)
wget http://couscous.io/couscous.phar && \
chmod +x couscous.phar && \
sudo mv couscous.phar /usr/local/bin/couscous

# Restart PHP and Nginx
sudo service php7.1-fpm restart
sudo service nginx restart
