#!/bin/bash
export DEPLOYER_NAME=ubuntu
export DEPLOYER_PASS=ubuntu
export TIMEZONE=${1}
export GITHUB_TOKEN=${2}

sudo apt-get -q -y update && \
sudo apt-get -q -y install git

sudo locale-gen en_US.UTF-8 && \
sudo sh -c 'export DEBIAN_FRONTEND=noninteractive; dpkg-reconfigure locales' && \
echo ${TIMEZONE} && \
sudo echo ${TIMEZONE} && \
sudo timedatectl set-timezone ${TIMEZONE}

sudo apt-get -q -y update --fix-missing && \
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing upgrade' && \
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing dist-upgrade';

sudo apt-get -q -y install \
    zsh \
    vim \
    make \
    gcc \
    g++ \
    ntp

sudo mkdir -p /var/xtuple/keys
sudo mkdir -p /home/${DEPLOYER_NAME}/xtuple

sudo mkdir -p /home/${DEPLOYER_NAME}/.github && \
sudo echo ${GITHUB_TOKEN} >> /home/${DEPLOYER_NAME}/.github/token && \
sudo chmod 600 /home/${DEPLOYER_NAME}/.github/token && \
sudo chown -R ${DEPLOYER_NAME}:${DEPLOYER_NAME} /home/${DEPLOYER_NAME}/.github

chsh -s /bin/zsh root
chsh -s /bin/zsh ${DEPLOYER_NAME}

sudo mkdir -p ~/.ssh && \
sudo ssh-keyscan -H github.com >> ~/.ssh/known_hosts && \
sudo ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts && \
sudo mkdir -p /home/${DEPLOYER_NAME}/.ssh && \
sudo cp ~/.ssh/known_hosts /home/${DEPLOYER_NAME}/.ssh/ && \
sudo chown -R ${DEPLOYER_NAME}:${DEPLOYER_NAME} /home/${DEPLOYER_NAME}/.ssh

sudo add-apt-repository -y ppa:ondrej/php && \
sudo apt-get -q -y update && \
sudo apt-get -q -y upgrade && \
sudo apt-get -q -y install \
  php-common \
  php7.1-common \
  php7.1-json \
  php7.1-opcache \
  php7.1-readline \
  php7.1 \
  php7.1-fpm \
  php7.1-xml \
  php-pear \
  php7.1-dev \
  php7.1-gd \
  php7.1-pgsql \
  php7.1-curl \
  php7.1-intl \
  php7.1-mcrypt \
  php7.1-mbstring \
  php7.1-soap

sudo apt-get -q -y install \
        php-xdebug && \
sudo mv /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/mods-available/xdebug.ini.original && \
sudo sh -c "cat << EOF > /etc/php/7.1/mods-available/xdebug.ini
zend_extension = xdebug.so
xdebug.max_nesting_level = 250
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.profiler_enable_trigger = 1
xdebug.profiler_output_dir = /vagrant/var/xdebug
xdebug.profiler_output_name = vagrant.out.%t.xdebug
EOF"

# Note: php.ini template is missing here, should be copy manually
export ESCAPED_TIMEZONE=$(echo ${TIMEZONE} | sed -e 's/[]\/$*.^|[]/\\&/g')
sudo cp /etc/php/7.1/cli/php.ini /etc/php/7.1/cli/php.ini.original && \
sudo sed -i "s/{TIMEZONE}/${ESCAPED_TIMEZONE}/g" /etc/php/7.1/cli/php.ini

# Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');" && \
sudo mv composer.phar /usr/local/bin/composer && \
sudo mkdir -p /home/${DEPLOYER_NAME}/.composer && \
sudo sh -c 'cat << EOF > '/home/${DEPLOYER_NAME}/.composer/config.json'
{
  "config": {
    "github-oauth": {
      "github.com": "{GITHUB_TOKEN}"
    },
    "process-timeout": 600,
    "preferred-install": "source",
    "github-protocols": ["ssh", "https", "git"],
    "secure-http": false
  }
}
EOF' && \
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

# Postgres
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
sudo apt-get -q -y update && \
sudo apt-get -q -y install postgresql-9.6

sudo -i -u postgres psql postgres --command="CREATE USER ${DEPLOYER_NAME} PASSWORD '${DEPLOYER_PASS}'"

sudo cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.original && \
sudo echo "Copy pg_hba.conf manually" #cp ${CONFIG_DIR}/postgres/pg_hba-${TYPE}.conf /etc/postgresql/9.6/main/pg_hba.conf

sudo service postgresql restart

# Compass
sudo apt-get -q -y install rubygems && \
sudo apt-get -q -y install rubygems-integration && \
sudo apt-get -q -y install ruby-dev && \
sudo gem install compass

# ZSH
sudo su -c 'curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh'
cd /home/${DEPLOYER_NAME} && sudo su -c "curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh" ${DEPLOYER_NAME}
sudo chsh -s /usr/bin/zsh ${DEPLOYER_NAME}

sudo cp /home/${DEPLOYER_NAME}/.zshrc /home/${DEPLOYER_NAME}/.zshrc.original && \
echo 'export PATH="/home/'${DEPLOYER_NAME}'/.composer/vendor/bin":$PATH' >> /home/${DEPLOYER_NAME}/.zshrc && \
echo 'export COMPOSER_DISABLE_XDEBUG_WARN=1' >> /home/${DEPLOYER_NAME}/.zshrc

sudo apt-get -q -y autoremove
