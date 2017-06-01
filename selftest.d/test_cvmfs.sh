#!/bin/bash

#RUN_IN_CONTAINER cvmfs

set -o errexit # bail out on all errors immediately
set -x

# Check the squid proxy is running
squid -k check || exit 1

# Check the reachability of Stratum 1 servers
SQUID_STRATUM1=`cat etc/squid/squid.conf | grep -v '^#' | grep 'acl cvmfs dst' | cut -d ' ' -f 4 | tr '\n' ' '`

# Probe CVMFS endpoint
cvmfs_config probe || exit 1

# Try to read a file (same path of software for Jupyter Notebooks)
#CVMFS_TEST="/cvmfs/sft.cern.ch/lcg/views/LCG_88/x86_64-slc6-gcc49-opt/setup.sh"
CVMFS_TEST="/cvmfs/sft.cern.ch/lcg/views/LCG_88/x86_64-slc6-gcc62-opt/setup.sh"
cat $CVMFS_TEST > /dev/null || exit 1

### Ping CVMFS repository

# Note: This is collapsing to localhost in case of local squid proxy
CVMFS_PROXY=`cat /etc/cvmfs/default.local | grep -v '^#' | grep CVMFS_HTTP_PROXY | cut -d '=' -f 2 | tr '|' '\n' | tr ';' '\n' | grep -v "ca-proxy" | grep -v "DIRECT" | tr '\n' ' ' | sed 's/http:\/\///g' | sed 's/:3128//g' | tr -d "'"`

# Note: Used only in case of DIRECT connection to Stratum 1 without local squid proxy
CVMFS_SERVER=`cat /etc/cvmfs/domain.d/cern.ch.conf | grep -v "^#" | grep CVMFS_SERVER_URL | cut -d '=' -f 2 | sed 's/http:\/\///g' | sed 's/\/cvmfs\/@fqrn@//g' | tr -d '"' | tr ';' ' '`

# Check the reachability of Stratum 1 servers (destinations of local squid proxy)
SQUID_STRATUM1=`cat etc/squid/squid.conf | grep -v '^#' | grep 'acl cvmfs dst' | cut -d ' ' -f 4 | tr '\n' ' '`

for i in $CVMFS_PROXY $CVMFS_SERVER $SQUID_STRATUM1 ;
do
	ping -c 5 -i 0.2 -w 5 $i || exit 0
done

