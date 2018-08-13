#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- Install the required software on the host ----- #
install_software()
{
  yum -y install \
    wget \
    git \
    fuse \
    net-tools \
    envsubst

  echo "Installing docker..."
  wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-"$DOCKER_VERSION"-1.el7.centos.x86_64.rpm
  wget https://download.docker.com/linux/centos/7/`uname -m`	/stable/Packages/docker-ce-18.03.0.ce-1.el7.centos.x86_64.rpm
  wget https://get.docker.com -O /tmp/getdocker.sh
  mkdir -p /var/lib/docker
  bash /tmp/getdocker.sh
  rm /tmp/getdocker.sh

  echo "Installing docker-compose..."
  wget https://github.com/docker/compose/releases/download/"$DOCKERCOMPOSE_VERSION"/docker-compose-Linux-x86_64 -O /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose

  echo "Starting docker daemon..."
  service docker start
  docker --version
  docker-compose --version
}

# Check to be root
need_root

# Raise warning about software installation
warn_about_software_requirements

echo""
read -r -p "Do you want to proceed with the installation [y/N] " response
case "$response" in
  [yY]) 
    echo "Installing required software..."
    install_software
  ;;
  *)
    echo "Exiting..."
  ;;
esac
