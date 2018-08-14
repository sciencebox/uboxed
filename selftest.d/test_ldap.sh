#!/bin/bash
set -o errexit # bail out on all errors immediately
set -x

source /selftest.d/.env

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT_DIR=$CWD"/ldap_results"
LDAP_OUT=$OUTPUT_DIR"/ldap.log"
PAM_OUT=$OUTPUT_DIR"/pam.log"
mkdir -p $OUTPUT_DIR

LDAP_CLIENTS="eos-mq eos-mgm eos-fuse cernbox jupyterhub"


# Query LDAP server and contrast obtained results
# 1.from LDAP container itself (check you have some users and generate groundtruth)
docker exec ldap ldapsearch -x -H $LDAP_URI -b $LDAP_BASE_DN -D $LDAP_ADMIN_BIND_DN -w $LDAP_ADMIN_BIND_PASSWORD > $LDAP_OUT

# 2.from other containers
for i in $LDAP_CLIENTS;
do
  docker exec $i ldapsearch -x -H $LDAP_URI -b $LDAP_BASE_DN -D $LDAP_ADMIN_BIND_DN -w $LDAP_ADMIN_BIND_PASSWORD > $LDAP_OUT.$i
  diff $LDAP_OUT $LDAP_OUT.$i || exit 1
done


# Check to be able to retrieve account info via NSS/PAM
USERLIST=`cat $LDAP_OUT | grep uid: | cut -d ' ' -f 2 | tr '\n' ' ' | head -n 10`
for i in $LDAP_CLIENTS;
do
  # eos-mq does not have ldap access via NSS/PAM and is expectd to fail
  if [ "$i" == "eos-mq" ];
  then
    only_one_user=`echo $USERLIST | cut -d ' ' -f 1`
    docker exec $i id $only_one_user && echo "ERROR: eos-mq should fail (no nss/pam configured) but succeeded" && exit 1
    continue
  fi

  # for all the othe containers, scan user list
  for un in $USERLIST;
  do
    docker exec $i id $un >> $PAM_OUT.$i || exit 1
  done
done

