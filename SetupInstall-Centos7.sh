#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- Install the required gpu software on the host ----- #
install_gpu_software()
{
  echo "Installing nvidia-docker2..."
  yum install -y https://nvidia.github.io/nvidia-container-runtime/centos7/x86_64/nvidia-container-runtime-"$NVIDIA_CONTAINER_RUNTIME_VERSION"-1.x86_64.rpm \
                 https://nvidia.github.io/libnvidia-container/centos7/x86_64/libnvidia-container1-"$LIBNVIDIA_CONTAINER_VERSION"-1.x86_64.rpm \
                 https://nvidia.github.io/libnvidia-container/centos7/x86_64/libnvidia-container-tools-"$LIBNVIDIA_CONTAINER_VERSION"-1.x86_64.rpm \
                 https://nvidia.github.io/nvidia-container-runtime/centos7/x86_64/nvidia-container-runtime-hook-"$NVIDIA_CONTAINER_RUNTIME_HOOK_VERSION"-2.x86_64.rpm \
                 https://nvidia.github.io/nvidia-docker/centos7/x86_64/nvidia-docker2-"$NVIDIA_DOCKER_VERSION".noarch.rpm 

  
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
  yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-"$DOCKER_VERSION".ce-3.el7.x86_64.rpm

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
    exit 0
  ;;
esac

# Raise warning about GPU software installation (docker-ce should be installed)
warn_about_gpu_software_requirements

echo ""
read -r -p "Do you want to proceed with the gpu software installation [y/N] " response
case "$response" in
  [yY]) 
    echo "Installing required gpu software..."
    install_gpu_software
  ;;
  *)
    echo "Continuing without GPU support"
  ;;
esac
