#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- Install the required software on the host ----- #
install_software()
{
  apt-get install \
    wget \
    git \
    fuse \
    net-tools \
    gettext

  echo "Installing docker..."
  wget https://download.docker.com/linux/ubuntu/dists/`lsb_release -c -s`/pool/stable/amd64/docker-ce_"$DOCKER_VERSION"~ce-0~ubuntu_amd64.deb -O /tmp/docker-ce.deb
  dpkg -i /tmp/docker-ce.deb
  rm -f /tmp/docker-ce.deb

  echo "Installing docker-compose..."
  wget https://github.com/docker/compose/releases/download/"$DOCKERCOMPOSE_VERSION"/docker-compose-`uname -s`-`uname -m` -O /usr/local/bin/docker-compose
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

echo ""
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
