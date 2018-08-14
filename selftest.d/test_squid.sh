#!/bin/bash

#RUN_IN_CONTAINER cvmfs

set -o errexit # bail out on all errors immediately
set -x

# Check the squid proxy is running
squid -k check || exit 1

# Check the reachability of Stratum 1 servers
SQUID_STRATUM1=`cat etc/squid/squid.conf | grep -v '^#' | grep 'acl cvmfs dst' | cut -d ' ' -f 4 | tr '\n' ' '`

# Check the reachability of Stratum 1 servers (destinations of local squid proxy)
SQUID_STRATUM1=`cat etc/squid/squid.conf | grep -v '^#' | grep 'acl cvmfs dst' | cut -d ' ' -f 4 | tr '\n' ' '`

for i in $SQUID_STRATUM1 ;
do
	ping -c 5 -i 0.2 -w 5 $i || exit 0
done

