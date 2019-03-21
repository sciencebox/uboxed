#!/bin/bash

export RUN_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"	# This is the folder from where this scripts runs

# Import variables and functions
source etc/common.sh

# Preliminary Checks
echo ""
echo "Preliminary checks..."
need_root
check_required_services_are_available
warn_about_interfence_eos_cvmfs
create_env_file

# Clean-Up
check_single_user_container_running "start"
stop_and_remove_containers
cleanup_folders_for_fusemount
initialize_folders_for_fusemount

# Preparation
docker_network
volumes_for_ldap
volumes_for_eos
volumes_for_mysql
fetch_singleuser_notebook_image
fetch_sciencebox_images
check_to_have_all_images
check_ports_availability
set_the_locks
if check_override_certificates; then
  copy_override_certificates
fi

# Run via Docker Compose
echo ""
echo "Run via docker-compose..."
docker-compose -f $DOCKERCOMPOSE_FILE up -d

# Notify the user with the progression
LDAP_DONE=false
EOS_MGM_DONE=false
EOS_FST_DONE=false
echo
echo "Configuring:"
echo "  - Initialization"
while [[ -f "$HOST_FOLDER"/usercontrol-lock ]]
do
  if [[ ! -f "$HOST_FOLDER"/eos-mgm-lock && "$LDAP_DONE" == "false" ]]; then
    echo "  - LDAP"
    LDAP_DONE=true
  fi
  if [[ ! -f "$HOST_FOLDER"/eos-fst-lock && "$EOS_MGM_DONE" == "false" ]]; then
    echo "  - EOS headnode"
    EOS_MGM_DONE=true
  fi
  if [[ ! -f "$HOST_FOLDER"/eos-fuse-lock && "$EOS_FST_DONE" == "false" ]]; then
    echo "  - EOS storage servers"
    EOS_FST_DONE=true
  fi
  sleep 3
done

echo "  - CERNBox"
echo "  - SWAN"

echo ""
echo "Configuration complete!"

echo ""
echo "Access to log files: docker-compose logs -f"
echo "Or get them sorted in time: docker-compose logs -t | sort -t '|' -k +2d"
echo "--> Please source the uboxed/etc/common.sh file first! <--"

