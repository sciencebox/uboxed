#! /bin/bash

export RUN_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"   # This is the folder from where this scripts runs


echo "Setting up the tests..."
echo "This might take some time as a specific Docker image is being built"
echo "  Logfile: # less test-setup.log"

{
    set -o verbose
    docker build -t selftest -f selftest.Dockerfile .
    docker rm -f selftest
    docker run -d -it --name selftest --network demonet --volume /var/run/docker.sock:/var/run/docker.sock:rw selftest
    set +o verbose
} > test-setup.log 2>&1

echo ""
echo "Done with the Docker image."

echo ""
echo "Running all tests..."
echo "  Logfile: # docker exec -it selftest less /selftest.d/test.log"

docker exec -it selftest bash /selftest.d/run_all_tests.sh
