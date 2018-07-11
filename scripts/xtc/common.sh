#!/bin/bash
export TYPE=${1}
export TIMEZONE=${2}
export ROOT_PASS=${3}
export CONFIG_DIR=${4}
export HOST_USERNAME=${5}

sudo locale-gen en_US.UTF-8 && \
sudo sh -c 'export DEBIAN_FRONTEND=noninteractive; dpkg-reconfigure locales' && \
echo ${TIMEZONE} && \
sudo echo ${TIMEZONE} && \
sudo timedatectl set-timezone ${TIMEZONE}

if [ ${TYPE} = 'server' ]; then
    echo "root:${ROOT_PASS}" | sudo chpasswd
fi

sudo apt-get -q -y update --fix-missing && \
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing upgrade' && \
sudo sh -c 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing dist-upgrade';

if [ ${TYPE} = 'server' ]; then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original && \
    sudo chmod a-w /etc/ssh/sshd_config.original && \
    sudo cp ${CONFIG_DIR}/ssh/sshd_config.conf /etc/ssh/sshd_config && \
    sudo restart ssh
fi

sudo apt-get -q -y install \
    vim \
    make \
    gcc \
    g++ \
    ntp

if [ ${TYPE} = 'server' ]; then
  sudo mkdir -p /var/xtuple/keys
else
  sudo mkdir -p /var/xtuple && \
  sudo ln -s /vagrant/xtuple/keys /var/xtuple/keys
fi

if [ ${TYPE} = 'vagrant' ]; then
    HOST_UID=$(stat -c '%u' /vagrant) && \
    HOST_GROUP=$(stat -c '%G' /vagrant) && \
    sudo adduser --system --no-create-home --uid ${HOST_UID} --ingroup ${HOST_GROUP} ${HOST_USERNAME}
fi
