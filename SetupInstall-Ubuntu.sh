#!/bin/bash

# Import variables and functions
source etc/common.sh

# ----- Install the required gpu software on the host ----- #
install_gpu_software()
{

  echo "Installing nvidia-docker2..."
  # Add the package repositories
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  sudo apt-get update

  # Install nvidia-docker2 and reload the Docker daemon configuration
  sudo apt-get install -y nvidia-docker2
  
  echo "Checking NVidia driver"
  check_nvidia_driver

}

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
  wget https://github.com/docker/compose/releases/download/"$DOCKERCOMPOSE_VERSION"/docker-compose-`uname -s`-`uname -m` -O /usr/bin/docker-compose
  chmod +x /usr/bin/docker-compose

  echo "Starting docker daemon..."
  service docker start
  docker --version
  docker-compose --version
}

# Check to be root
need_root

# Raise warning about GPU software installation
warn_about_gpu_software_requirements

echo ""
read -r -p "Do you want to proceed with the gpu software installation [y/N] " response
case "$response" in
  [yY]) 
    echo "Installing required gpu software..."
    install_gpu_software
  ;;
  *)
    echo "Exiting..."
  ;;
esac


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
