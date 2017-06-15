#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- Install the required software on the host ----- #
install_software()
{
	yum -y install \
			wget \
			git \
			fuse

	echo "Installing docker..."
	wget -q https://get.docker.com -O /tmp/getdocker.sh
	mkdir -p /var/lib/docker
	bash /tmp/getdocker.sh
	rm /tmp/getdocker.sh

	echo "Installing docker-compose..."
	wget -q https://github.com/docker/compose/releases/download/"$DOCKERCOMPOSE_VERSION"/docker-compose-`uname -s`-`uname -m` -O /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

	echo "Starting docker daemon..."
	service docker start
	docker --version
	docker-compose --version
}

# Check to be root
need_root

# Raise warning about software installation
echo ""
echo "The following software has to be installed or updated:"
echo -e "\t- wget"
echo -e "\t- fuse"
echo -e "\t- git"
echo -e "\t- docker (version 17.03.1-ce or greater)"
echo -e "\t- docker-compose (version 1.11.2 or greater)"
echo ""
read -r -p "Do you want to proceed with the installation [y/N] " response
case "$response" in
    [yY]) 
		echo "Installing required software..."
		install_software
        ;;
    *)
        ;;
esac


