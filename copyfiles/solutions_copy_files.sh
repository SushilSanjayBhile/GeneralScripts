#!/bin/bash
set -x

# clean rpm directory
ssh diamanti@vagserv1 -t  "rm ~/rpms/*"
ssh diamanti@vagserv1 -t  "mkdir ~/rpms"

# copy rpm files from current directory to vagserv1
scp ./*.rpm diamanti@vagserv1:~/rpms/

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@solcntl -t \"rm rpms/*\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "scp ~/rpms/*.rpm solcntl:~/rpms/"

# clean controllers rpms directory
ssh diamanti@vagserv1 -t "ssh diamanti@solcntl -t \"ssh diamanti@solserv10 -t 'rm ~/rpms/*'\""

# create rpms directory
ssh diamanti@vagserv1 -t "ssh solcntl -t \"ssh solserv12 -t \"mkdir ~/rpms\"\""
ssh diamanti@vagserv1 -t "ssh solcntl -t \"ssh solserv11 -t 'mkdir ~/rpms/'\""
ssh diamanti@vagserv1 -t "ssh solcntl -t \"ssh solserv10 -t 'mkdir ~/rpms/'\""

# copy rpm files from vagserv to solcntl
ssh diamanti@vagserv1 -t "ssh solcntl -t \"scp ~/rpms/* solserv12:~/rpms/\""
ssh diamanti@vagserv1 -t "ssh solcntl -t \"scp ~/rpms/* solserv10:~/rpms/\""
ssh diamanti@vagserv1 -t "ssh solcntl -t \"scp ~/rpms/* solserv11:~/rpms/\""
