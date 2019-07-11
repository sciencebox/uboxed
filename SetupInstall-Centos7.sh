#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- Install the required gpu software on the host ----- #
install_gpu_software()
{
  echo "Installing nvidia-docker2..."
  # Add the package repositories
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
  sudo tee /etc/yum.repos.d/nvidia-docker.repo

  # Install nvidia-docker2 and reload the Docker daemon configuration
  sudo yum install -y nvidia-docker2
  
  echo "Checking NVidia driver"
  check_nvidia_driver
}

# ----- Install the required software on the host ----- #
install_software()
{
  yum -y install \
    wget \
    git \
    fuse \
    net-tools \
    gettext

  echo "Installing docker..."
  yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-"$DOCKER_VERSION".ce-1.el7.centos.x86_64.rpm

  echo "Installing docker-compose..."
  wget https://github.com/docker/compose/releases/download/"$DOCKERCOMPOSE_VERSION"/docker-compose-Linux-x86_64 -O /usr/bin/docker-compose
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
