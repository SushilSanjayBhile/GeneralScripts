#!/bin/bash
set -x

# clean rpm directory
ssh diamanti@vagserv1 -t  "rm ~/rpms/*"

# copy rpm files from current directory to vagserv1
scp ./*.rpm diamanti@vagserv1:~/rpms/

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@solcntl -t \"rm rpms/*\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "scp ~/rpms/*.rpm solcntl:~/rpms/"

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@solcntl -t \"ssh diamanti@solserv10 -t 'rm ~/rpms/*'\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "ssh solcntl -t \"scp ~/rpms/* solserv10:~/rpms/\""
