#!/bin/bash
set -o errexit # bail out on all errors immediately
set -x

export CERNBOXURL=https://cernboxgateway/cernbox/desktop/remote.php/webdav

dd if=/dev/zero of=/tmp/largefile256.dat bs=1024 count=250
dd if=/dev/zero of=/tmp/largefile512.dat bs=1024 count=500
dd if=/dev/zero of=/tmp/largefile1024.dat bs=1024 count=1000
dd if=/dev/zero of=/tmp/largefile10240.dat bs=1024 count=10000


FILES="/etc/passwd /tmp/largefile256.dat /tmp/largefile512.dat /tmp/largefile1024.dat /tmp/largefile10240.dat"

for ff in $FILES; do

    f=`basename $ff`

    # upload
    curl -f -k -u user0:test0 --upload-file $ff ${CERNBOXURL}/home/$f || exit 1
    
    # overwrite file
    curl -f -k -u user0:test0 --upload-file $ff ${CERNBOXURL}/home/$f || exit 1
    
    # download
    curl -f -k -u user0:test0 ${CERNBOXURL}/home/$f > /dev/null || exit 1
done


# test expected failures

curl -s -f -k -u user0:test1 --upload-file /etc/passwd ${CERNBOXURL}/home/passwd && echo "ERROR: PUT request should fail (wrong password) but succeeded" && exit 1

curl -s -f -k -u user0:test0 --upload-file /etc/passwd ${CERNBOXURL}/wronghome/passwd && echo "ERROR: PUT request should fail (wrong URI) but succeeded" && exit 1

curl -s -f -k -u user0:test0 ${CERNBOXURL}/home/passwd_does_not_exist_1234 > /dev/null && echo "ERROR: GET request should fail (no file on the server) but succeeded " && exit 1

exit 0
