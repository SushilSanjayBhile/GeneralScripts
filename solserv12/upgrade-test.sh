currentrpm=$(sudo rpm -qa | grep diamanti | grep spektra)   # first this gets removed

rpm="3.2.0-118"     # then this gets installed  # then this gets removed

desiredrpm="3.3.0-84"   # then this gets installed
desiredrpm="0.0.1-test5"

present=$(rpm -qa | grep diaman | grep ${currentrpm})
if [ "$present" != "" ]; then
	echo "REMOVING ${currentrpm} RPM in 10 seconds, cleanup spektra"
	echo "Installing spektra-${rpm}..."
	sleep 10

	sudo rpm -e ${currentrpm}
	sleep 3

	sudo rpm -ivh ~/rpms/diamanti-spektra-${rpm}.x86_64.rpm
	
	echo "RPM INSTALLATION DONE"
	sleep 5

	init_spektra.sh
	sleep 3
	../useful_to_all/test.sh
	echo "INIT SPEKTRA DONE"
	sleep 10

	dev_init.sh
	sleep 3
	../useful_to_all/test.sh
	echo "dev SPEKTRA DONE"
	sleep 10

	/home/diamanti/sushil/GeneralScripts/solserv12/adopt-cluster.sh
	sleep 3
	../useful_to_all/test.sh
	echo "adoption DONE"
	sleep 10
fi
sleep 3
image=$(sudo docker images | grep spektrasvc  | grep test5 | awk '{print $3}')
sudo docker rmi $image

present=$(rpm -qa | grep diaman | grep spektra | grep "${rpm}")
if [ "$present" != "" ]; then
	echo "REMOVING ${rpm} RPM in 10 seconds, cleanup spektra"
	echo "Installing spektra-${desiredrpm}..."
	sleep 10

	sudo rpm -e diamanti-spektra-${rpm}.x86_64
	sleep 5

	sudo rpm -ivh ~/rpms/diamanti-spektra-${desiredrpm}.x86_64.rpm
	echo "RPM INSTALLATION DONE"
	sleep 5

	init_spektra.sh
	sleep 5
	for i in {1..10}; do ~/sushil/GeneralScripts/useful_to_all/pull_all_failed_docker_images.sh ; done
	../useful_to_all/test.sh
fi
