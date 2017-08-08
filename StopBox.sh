#!/bin/bash

export RUN_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"	# This is the folder from where this scripts runs

# Import variables and functions
source etc/common.sh


# ----- STOP ----- #
echo ""
echo "WARNING: This script will terminate the running services (i.e., EOS, CERNBox, SWAN) and remove Docker containers."
read -r -p "Do you want to continue [y/N] " response
case "$response" in
    [yY])
        echo "Ok."
        ;;
    *)
        echo "Cannot continue. Exiting..."
        echo ""
        exit 1
        ;;
esac


# Preliminary Checks
echo ""
echo "Preliminary checks..."
need_root
#check_eos_codename
check_required_services_are_available
#warn_about_software_requirements
#warn_about_interfence_eos_cvmfs

# Removing Containers
check_single_user_container_running "stop"
stop_and_remove_containers
cleanup_folders_for_fusemount

# Removing docker network
docker_network_remove

