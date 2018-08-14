#!/bin/bash
set -o errexit # bail out on all errors immediately
set -x

RUNNING_CONTAINERS="cernbox cernboxgateway cvmfs eos-fst1 eos-fst2 eos-fst3 eos-fst4 eos-fuse eos-mgm eos-mq jupyterhub ldap" 
SERVICE_CONTAINERS="ldap-ldapadd"


# Basic reachability test with ping
for i in $RUNNING_CONTAINERS;
do
  ping -c 1 -w 5 $i || exit 1 
done

# Service containers are expected to fail
for i in $SERVICE_CONTAINERS;
do
  ping -c 1 -w 5 $i && echo "ERROR: Container $i replied to ping but should be exited" && exit 1
done

# Check open ports with nmap
for i in $RUNNING_CONTAINERS;
do
  nmap -PS --max-retries 0 --host-timeout 10s $i || exit 1
done

