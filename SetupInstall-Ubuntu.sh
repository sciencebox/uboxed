#!/bin/bash

# Import variables and functions
source etc/common.sh

# ----- Install the required gpu software on the host ----- #
install_gpu_software()
{

  echo "Installing nvidia-docker2..."
  apt-get install -y runc

  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)  
  wget  https://nvidia.github.io/libnvidia-container/"$distribution"/amd64/libnvidia-container1_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb -O /tmp/libnvidia-container1_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb
  wget  https://nvidia.github.io/libnvidia-container/"$distribution"/amd64/libnvidia-container-tools_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb -O /tmp/libnvidia-container-tools_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb
  wget  https://nvidia.github.io/nvidia-container-runtime/"$distribution"/amd64/nvidia-container-runtime-hook_"$NVIDIA_CONTAINER_RUNTIME_HOOK_VERSION"-1_amd64.deb -O /tmp/nvidia-container-runtime-hook_"$NVIDIA_CONTAINER_RUNTIME_HOOK_VERSION"-1_amd64.deb
  wget  https://nvidia.github.io/nvidia-container-runtime/"$distribution"/amd64/nvidia-container-runtime_"$NVIDIA_CONTAINER_RUNTIME_VERSION"-1_amd64.deb -O /tmp/nvidia-container-runtime_"$NVIDIA_CONTAINER_RUNTIME_VERSION"-1_amd64.deb
  wget  https://nvidia.github.io/nvidia-docker/"$distribution"/amd64/nvidia-docker2_"$NVIDIA_DOCKER_VERSION"-1_all.deb -O /tmp/nvidia-docker2_"$NVIDIA_DOCKER_VERSION"-1_all.deb

  dpkg -i /tmp/libnvidia-container1_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb \
          /tmp/libnvidia-container-tools_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb \
          /tmp/nvidia-container-runtime-hook_"$NVIDIA_CONTAINER_RUNTIME_HOOK_VERSION"-1_amd64.deb \
          /tmp/nvidia-container-runtime_"$NVIDIA_CONTAINER_RUNTIME_VERSION"-1_amd64.deb \
          /tmp/nvidia-docker2_"$NVIDIA_DOCKER_VERSION"-1_all.deb

  rm /tmp/libnvidia-container1_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb \
          /tmp/libnvidia-container-tools_"$LIBNVIDIA_CONTAINER_VERSION"-1_amd64.deb \
          /tmp/nvidia-container-runtime-hook_"$NVIDIA_CONTAINER_RUNTIME_HOOK_VERSION"-1_amd64.deb \
          /tmp/nvidia-container-runtime_"$NVIDIA_CONTAINER_RUNTIME_VERSION"-1_amd64.deb \
          /tmp/nvidia-docker2_"$NVIDIA_DOCKER_VERSION"-1_all.deb

  echo "Restarting docker daemon with NVidia runtime..."
  service docker restart
  
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
  wget https://download.docker.com/linux/ubuntu/dists/`lsb_release -c -s`/pool/stable/amd64/docker-ce_"$DOCKER_VERSION"~ce~3-0~ubuntu_amd64.deb -O /tmp/docker-ce.deb
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
