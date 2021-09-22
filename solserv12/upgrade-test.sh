present=$(rpm -qa | grep diaman | grep test)
echo $present
echo "REMOVING TEST RPM in 10 seconds, cleanup spektra"
sleep 10

if [ "$present" != "" ]; then
	sudo rpm -e diamanti-spektra-0.0.1-test5.x86_64
	sleep 3

	# for 3.2.1 testing=> TESTED:OKAY
	#sudo rpm -ivh ~/rpms/diamanti-spektra-3.2.1-159.x86_64.rpm

	# for 3.2.0 testing
	#sudo rpm -ivh ~/rpms/diamanti-spektra-3.2.0-118.x86_64.rpm

	# for 3.1.1 testing
	sudo rpm -ivh ~/rpms/diamanti-spektra-3.1.1-110.x86_64.rpm
	
	echo "RPM INSTALLATION DONE"
	sleep 5

	init_spektra.sh
	sleep 3
	while [ 1 ]; do echo; kubectl get pods -A --no-headers | awk '{print $6}'  | grep -v m | grep -v d | grep -v h; if [ $? -ne 0 ]; then a=$((a+1)); break; echo; fi; sleep 3; done
	echo "INIT SPEKTRA DONE"
	sleep 10

	dev_init.sh
	sleep 3
	/home/diamanti/sushil/GeneralScripts/solserv12/test.sh
	echo "dev SPEKTRA DONE"
	sleep 10

	/home/diamanti/sushil/GeneralScripts/solserv12/adopt-cluster.sh
	sleep 3
	/home/diamanti/sushil/GeneralScripts/solserv12/test.sh
	echo "adoption DONE"
	sleep 10
fi

sleep 3

image=$(sudo docker images | grep spektrasvc  | grep test5 | awk '{print $3}')
sudo docker rmi $image

#diamanti-spektra-3.2.0-118.x86_64
present=$(rpm -qa | grep diaman | grep spektra | grep "3.1.1-110")
echo $present
if [ "$present" != "" ]; then
	#sudo rpm -e diamanti-spektra-3.2.1-159.x86_64
	#sudo rpm -e diamanti-spektra-3.2.0-118.x86_64
	sudo rpm -e diamanti-spektra-3.1.1-110.x86_64
	sleep 3

	sudo rpm -ivh ~/rpms/diamanti-spektra-0.0.1-test5.x86_64.rpm
	echo "RPM INSTALLATION DONE"
	sleep 5

	init_spektra.sh
	sleep 5
	for i in {1..10}; do ~/sushil/GeneralScripts/useful_to_all/pull_all_failed_docker_images.sh ; done
	/home/diamanti/sushil/GeneralScripts/solserv12/test.sh
fi
