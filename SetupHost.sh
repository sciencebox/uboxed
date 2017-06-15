#!/bin/bash

# Import variables and functions
source etc/common.sh


# ----- DEPLOY ----- #
# Preliminary Checks
echo ""
echo "Preliminary checks..."
need_root
check_eos_codename
check_required_services_are_available
warn_about_software_requirements
warn_about_interfence_eos_cvmfs

# Clean-Up
check_single_user_container_running
stop_and_remove_containers
cleanup_folders_for_fusemount
initialize_folders_for_fusemount

# Preparation
docker_network
volumes_for_eos
volumes_for_ldap
volumes_for_cernbox

fetch_singleuser_notebook_image
fetch_system_component_images
check_to_have_all_images
check_ports_availability
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
echo "Or get them sorted in time: docker-compose logs -t | sort -t '|' -k +2d"
echo "--> Please source the uboxed/etc/common.sh file first! <--"

