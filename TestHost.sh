#! /bin/bash

export RUN_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"   # This is the folder from where this scripts runs
export IMAGE_NAME='gitlab-registry.cern.ch/sciencebox/docker-images/selftest:latest'

echo ""
echo "Setting up the tests..."

echo ""
echo "Pulling Docker image..."
docker pull gitlab-registry.cern.ch/sciencebox/docker-images/selftest
docker rm -f selftest >/dev/null 2>&1

echo ""
echo "Starting the container..."
docker rm -f selftest >/dev/null 2>&1
docker run -d -it --name selftest --network demonet --volume /var/run/docker.sock:/var/run/docker.sock:rw $IMAGE_NAME
docker cp .env selftest:/root/selftest.d/.env

echo ""
echo "Running all tests..."
echo "  Logfile: # docker exec -it selftest less /root/selftest.d/test.log"
docker exec -it selftest bash /root/selftest.d/run_all_tests.sh
