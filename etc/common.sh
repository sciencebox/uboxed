#!/bin/bash
# Shared variables and functions


# ----- Variables ----- #
# Host properties 
export BOX_HOSTNAME=`hostname --fqdn`


# Temporary folder on the host for deployment orchestration and fuse mounts
export HOST_FOLDER="/tmp/SWAN-in-Docker"
export CVMFS_FOLDER=$HOST_FOLDER"/cvmfs_mount"
export EOS_FOLDER=$HOST_FOLDER"/eos_mount"

# Network
export DOCKER_NETWORK_NAME="demonet"

# Images to be pulled
NOTEBOOK_IMAGES=(cernphsft/systemuser:v2.9) # , jupyter/minimal-notebook)
SYS_IMAGES=(cernbox cernboxgateway eos-controller eos-storage openldap selftest swan_cvmfs swan_eos-fuse swan_jupyterhub)
SYSIM_LOGIN="https://gitlab-registry.cern.ch"
SYSIM_REPO="gitlab-registry.cern.ch/cernbox/boxed"
SYSIM_PRIVATE=true

# LDAP volume names
LDAP_DB="openldap_database"
LDAP_CF="openldap_config"

### EOS
#TODO: This is not used for the moment
EOS_SUPPORTED_VERSIONS=(AQUAMARINE CITRINE)
EOS_CODENAME="AQUAMARINE"	# Pick one among EOS_SUPPORTED_VERSIONS

# EOS volume names
#TODO: These names should be forwarded to the eos deployment script
#TODO: Used only to define volume names for the moment
EOSSTORAGE_HEADING="eos-"
EOSSTORAGE_FST_AMOUNT=6
EOSSTORAGE_MGM="mgm"
EOSSTORAGE_MQ="mq"
EOSSTORAGE_FST_NAME="fst"


# ----- Functions ----- #
# Check to be root
function need_root {
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
else
	echo "I am root"
fi
}

# Print a warning about the required software on the host
function warn_about_software_requirements {
echo ""
echo "The following software has to be installed:"
echo -e "\t- wget"
echo -e "\t- fuse"
echo -e "\t- git"
echo -e "\t- docker (version 17.03.1-ce or greater)"
echo -e "\t- docker-compose (version 1.11.2 or greater)"
echo ""
echo "Please consider installing it manually or using the script SetupInstall-Centos7.sh (for CentOS 7 only)."
echo ""
}

# Check to have a valid EOS codename
function check_eos_codename {
for ver in ${EOS_SUPPORTED_VERSIONS[*]};
do
        if [[ "$ver" == "$EOS_CODENAME" ]];
        then
		echo "Valid EOS codename"
                return
        fi
done
echo "Unknown EOS codename. Cannot continue."
exit 1
}

# Wait for some time so that the user reads
function wait_for_user_read {
WAIT_FOR_USER_READ=10
while [ $WAIT_FOR_USER_READ -gt 0 ]; do
	echo -ne "\r$WAIT_FOR_USER_READ...\033[0K"
	sleep 1
	WAIT_FOR_USER_READ=$((WAIT_FOR_USER_READ-1))
done
echo "Continuing..."
}

# Print a warning about potential interference with EOS || CVMFS processes running on the host
function warn_about_interfence_eos_cvmfs {
echo ""
echo "WARNING: The deployment interferes with eventual CVMFS and EOS clients running on the host."
echo "All the running clients will be killed before proceeding."
read -r -p "Do you want to continue [y/N] " response
case "$response" in
    [yY])
        echo "Ok."
        ;;
    *)
        echo "Cannot continue. Exiting..."
        echo ""
        exit
        ;;
esac
}


# CLEANUP
# Remove old containers
function stop_and_remove_containers {
# WARNING: This is not going to work in case a single-user server is still running, e.g., jupyter-userN
#          Single-user's servers keep CVMFS and EOS locked due to internal mount
echo ""
echo "Removing containers..."
docker stop jupyterhub openldap openldap-ldapadd cvmfs eos-fuse cernbox cernboxgateway 2>/dev/null
docker rm -f jupyterhub openldap openldap-ldapadd cvmfs eos-fuse cernbox cernboxgateway 2>/dev/null

# NOTE: Containers for EOS storage are not managed by docker-compose
#       They need to be stopped and removed manually
docker stop eos-fst{1..6} eos-mq eos-mgm 2>/dev/null
docker rm -f eos-fst{1..6} eos-mq eos-mgm eos-controller 2>/dev/null
echo "Done."
}

# Remove folders with EOS || CVMFS fuse mount on the host
function cleanup_folders_for_fusemount {
echo ""
echo "Cleaning up folders..."
killall cvmfs2 2>/dev/null
killall eos 2>/dev/null
sleep 1
for i in `ls $CVMFS_FOLDER`
do
        fusermount -u $CVMFS_FOLDER/$i
        #umount -l $CVMFS_FOLDER/$i
done
fusermount -u $EOS_FOLDER
sleep 1
rm -rf $HOST_FOLDER 2>/dev/null
echo "Done."
}

# Re-initialize folders with EOS || CVMFS fuse mount 
function initialize_folders_for_fusemount {
echo ""
echo "Initializing folders..."
mkdir -p $HOST_FOLDER
touch "$HOST_FOLDER"/DO_NOT_WRITE_ANY_FILE_HERE
}


# PULL DOCKER IMAGES
# Single-user Jupyter Server
function fetch_singleuser_notebook_image {
# See: https://github.com/cernphsft/systemuser
echo ""
echo "Pulling Single-User notebook image..."
for i in ${NOTEBOOK_IMAGES[*]};
do
        docker pull $i
done
}

# All the other system components
function fetch_system_component_images {
echo ""
echo "Pulling system component images..."

if [ $SYSIM_PRIVATE ]; then
	echo "Log in to remote repository"
	docker login $SYSIM_LOGIN
fi
for i in ${SYS_IMAGES[*]};
do
        docker pull "$SYSIM_REPO":"$i"
        docker tag "$SYSIM_REPO":"$i" "$i":latest
	docker rmi "$SYSIM_REPO":"$i"
done
}


# DOCKER DEPLOYMENT
# Check to have (or create) a Docker network to allow communications among containers
function docker_network {
echo ""
echo "Setting up Docker network..."
docker network inspect $DOCKER_NETWORK_NAME >/dev/null 2>&1 || docker network create $DOCKER_NETWORK_NAME
docker network inspect $DOCKER_NETWORK_NAME
}

# Initialize volumes for EOS --> Make storage persistent
function volumes_for_eos {
echo ""
echo "Initialize Docker volumes for EOS..."
EOS_MGM=$EOSSTORAGE_HEADING$EOSSTORAGE_MGM
EOS_MQ=$EOSSTORAGE_HEADING$EOSSTORAGE_MQ
docker volume inspect $EOS_MQ >/dev/null 2>&1 || docker volume create --name $EOS_MQ
docker volume inspect $EOS_MGM >/dev/null 2>&1 || docker volume create --name $EOS_MGM
for i in {1..6}
do
    EOS_FST=$EOSSTORAGE_HEADING$EOSSTORAGE_FST_NAME$i
    docker volume inspect $EOS_FST >/dev/null 2>&1 || docker volume create --name $EOS_FST
done
}

# Initialize volumes for LDAP
function volumes_for_ldap {
echo ""
echo "Initialize Docker volume for LDAP..."
docker volume inspect $LDAP_DB >/dev/null 2>&1 || docker volume create --name $LDAP_DB
docker volume inspect $LDAP_CF >/dev/null 2>&1 || docker volume create --name $LDAP_CF
}

# Set locks to control dependencies and execution order
function set_the_locks {
echo ""
echo "Setting up locks..."
echo "Locking EOS-Storage -- Needs LDAP"
touch "$HOST_FOLDER"/eos-storage-lock
echo "Locking eos-fuse client -- Needs EOS storage"
touch "$HOST_FOLDER"/eos-fuse-lock
echo "Locking cernbox -- Needs EOS storage"
touch "$HOST_FOLDER"/cernbox-lock
echo "Locking cernboxgateway -- Needs EOS storage"
touch "$HOST_FOLDER"/cernboxgateway-lock
}

