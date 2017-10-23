# Dockerfile to run basic tests once the services are started
# NOTE: The container needs access to the Docker daemon socket on the host (/var/run/docker.sock:/var/run/docker.sock:rw) yo execute tests on the containers of services, e.g., JupyterHub, CVMFS, etc...

# Run command from the host:
#docker build -t selftest -f selftest.Dockerfile .; docker run --net demonet --name mt --rm --volume /var/run/docker.sock:/var/run/docker.sock:rw -it selftest


# ----- Use CERN cc7 as base image for EOS|FUSE ----- #
FROM cern/cc7-base:20170920

MAINTAINER Enrico Bocchi <enrico.bocchi@cern.ch>


# ----- Install the required software ----- #
RUN yum -y install wget
RUN wget -q https://get.docker.com -O /tmp/getdocker.sh && \
        bash /tmp/getdocker.sh && \
        rm /tmp/getdocker.sh

RUN yum -y install \
	less \
	nmap


# ----- Copy the test scripts ----- #
COPY selftest.d /selftest.d

CMD ["/bin/bash"]

