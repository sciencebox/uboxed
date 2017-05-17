#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- DEPLOY ----- #
# Preliminary Checks
echo ""
echo "Preliminary checks..."
need_root
check_eos_codename
warn_about_software_requirements
warn_about_interfence_eos_cvmfs

# Clean-Up
stop_and_remove_containers
cleanup_folders_for_fusemount
initialize_folders_for_fusemount

# Preparation
docker_network
volumes_for_eos
volumes_for_ldap

fetch_singleuser_notebook_image
fetch_system_component_images
set_the_locks


# Run via Docker Compose
echo ""
echo "Run via docker-compose..."
docker-compose up -d

echo
echo "Configuring..."
while [[ -f "$HOST_FOLDER"/usercontrol-lock ]]
do
        sleep 5        
done

echo ""
echo "Done!"
echo "Access to log files: docker-compose logs -f"



