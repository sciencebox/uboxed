# Dockerfile to run basic tests once the services are started
# NOTE: The container needs access to the Docker daemon socket on the host (/var/run/docker.sock:/var/run/docker.sock:rw) 
#		to execute tests on the containers of services, e.g., JupyterHub, CVMFS, etc...

#
# Run command from the host:
#docker build -t selftest -f selftest.Dockerfile .; docker run --net demonet --name mt --rm --volume /var/run/docker.sock:/var/run/docker.sock:rw -it selftest
#
# TODO: include in Docker Compose
#		Also set the related lock to wait for all the other services to be there
#

# ----- Use CERN cc7 as base image for EOS|FUSE ----- #
FROM cern/cc7-base:20170113

MAINTAINER Enrico Bocchi <enrico.bocchi@cern.ch>


RUN yum -y install yum-plugin-ovl # See http://unix.stackexchange.com/questions/348941/rpmdb-checksum-is-invalid-trying-to-install-gcc-in-a-centos-7-2-docker-image

# ----- Install the EOS|FUSE client ----- #
RUN yum -y update
RUN yum -y install nmap less

# ----- Install Docker to run commands against the other containers ----- #
RUN yum -y update
RUN yum -y install wget
RUN wget -q https://get.docker.com -O /tmp/getdocker.sh && \
	bash /tmp/getdocker.sh && \
	rm /tmp/getdocker.sh

COPY selftest.d /selftest.d

CMD ["/bin/bash"] #, "/tests.sh"]

