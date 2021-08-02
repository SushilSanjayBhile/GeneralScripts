#!/bin/bash
set -x

rm ./*rpm

wget http://bldserv1:8080/job/Project16-Master/lastSuccessfulBuild/artifact/artifacts/rpm/diamanti-spektra-9.9.1-1075.x86_64.rpm
wget http://bldserv1:8080/job/Project16-Master/lastSuccessfulBuild/artifact/artifacts/rpm/diamanti-cx-9.9.1-1075.x86_64.rpm

# clean rpm directory
ssh diamanti@vagserv1 -t  "mkdir ~/rpms"
ssh diamanti@vagserv1 -t  "rm ~/rpms/*"

# copy rpm files from current directory to vagserv1
scp ./*.rpm diamanti@vagserv1:~/rpms/

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@ltscntl -t \"mkdir rpms\""
ssh diamanti@vagserv1 -t "ssh diamanti@ltscntl -t \"rm rpms/*\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "scp ~/rpms/*.rpm ltscntl:~/rpms/"

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@ltscntl -t \"ssh diamanti@softserv1138 -t 'mkdir ~/rpms'\""
ssh diamanti@vagserv1 -t "ssh diamanti@ltscntl -t \"ssh diamanti@softserv1138 -t 'rm ~/rpms/*'\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "ssh ltscntl -t \"scp ~/rpms/* softserv1138:~/rpms/\""
