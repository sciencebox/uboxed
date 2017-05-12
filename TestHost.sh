
echo setting up the tests...  'logfile: # less test-setup.log'

{
    set -o verbose
    docker build -t selftest -f selftest.Dockerfile .
    docker rm -f selftest
    docker run -d -it --name selftest --network demonet --volume /var/run/docker.sock:/var/run/docker.sock:rw selftest
    set +o verbose
} > test-setup.log 2>&1

echo
echo running all tests...   'logfile: # docker exec -it selftest less /selftest.d/test.log'
echo 

docker exec -it selftest bash /selftest.d/run_all_tests.sh




