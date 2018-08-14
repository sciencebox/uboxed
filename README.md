# Welcome to BOXED
### *UBoxed -- Single-host Demo Deployment*

-----

https://cernbox.cern.ch/cernbox/doc/boxed

Self-contained, containerized demo for next-generation cloud storage and computing services for scientific and general-purpose use:

 - CERNBox: https://cernbox.web.cern.ch
 - EOS: https://eos.web.cern.ch
 - SWAN: https://swan.web.cern.ch
 - CVMFS: https://cvmfs.web.cern.ch


Packaging by: Enrico Bocchi, Hugo Gonzalez Labrador, Jozsef Makai, Jakub T. Moscicki


-----

### Quick setup

 1. Install required software on the host:

    For CentOS7:	`./SetupInstall-Centos7.sh`

    For Ubuntu:		`./SetupInstall-Ubuntu.sh`

    Please check [*] for supported OS versions.


 2. Setup and initialize all services: 

    `./SetupHost.sh`


 3. Quick test of the services:

    `./TestHost.sh`


 4. Go to: https://yourhost.yourdomain



### Stop services

 1. If you executed TestHost.sh at step 3 of the setup procedure, please stop the test container:

    `docker stop selftest`

    `docker rm selftest`


 2. Run the dedicated script:

    `./StopHost.sh`



### Remove Docker images and volumes

 1. Remove Docker images manually with:

    `docker rmi cernbox cernboxgateway eos-controller eos-storage ldap swan_cvmfs swan_eos-fuse swan_jupyterhub selftest cernphsft/systemuser:v2.10 cern/cc7-base:20170920`


 2. Remove Docker volumes

    WARNING: This will delete user's data!

    `docker volume rm cernbox_shares_db ldap_config ldap_database eos-fst1 eos-fst1_userdata eos-fst2 eos-fst2_userdata eos-fst3 eos-fst3_userdata eos-fst4 eos-fst4_userdata eos-fst5 eos-fst5_userdata eos-fst6 eos-fst6_userdata eos-mgm eos-mq`



-----

#### *Enjoy and give feedback to CERN/IT and CERN/EP.*

-----


*\*Host OS Support*

We test this package on CentOS 7.3 and Ubuntu 17.04 hosts and we recommend to use one of these two OSes.
The deployment on Ubuntu 14.04 and 16.04 requires the modification of the Docker storage driver to devicemapper.

For other OSes you may need some extra work (and sweat or tears). 
We are happy to hear from you and eventually include instructions for other OSes.


Required software on the host:

  - install wget, fuse
  - install docker (version 17.03.1-ce or greater)
  - install docker-compose (version 1.11.2 or greater)

-----

Copyright 2017, CERN.

AGPL License (http://www.gnu.org/licenses/agpl-3.0.html)

