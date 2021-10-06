currentrpm="$(sudo rpm -qa | grep diamanti | grep spektra)"

firstrpm="3.2.0-118"

rpmnew="3.3.0-84"
rpmnew="test6_vault_upgrade_way_change"

echo "This is current RPM: "${currentrpm}
echo "this is first rpm going to get installed: "${firstrpm}
echo "This is upgrad desired rpm: "${rpmnew}

echo
echo "Enter yes if you want to move ahead: "
read input
if [ "$input" == "yes" ]; then
	echo "yes"
else
	echo "exiting"
	exit
fi

present=$(rpm -qa | grep diaman | grep ${currentrpm})
if [ "$present" != "" ]; then
	echo "REMOVING ${currentrpm} RPM in 10 seconds, cleanup spektra"
	echo "Installing spektra-${firstrpm}..."
	sleep 10

	sudo rpm -e ${currentrpm}
	sleep 3

	sudo rpm -ivh ~/rpms/diamanti-spektra-${firstrpm}.x86_64.rpm
	
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

	./adopt-cluster.sh
	sleep 3
	../useful_to_all/test.sh
	echo "adoption DONE"
	sleep 10
fi
sleep 3

image=$(sudo docker images | grep spektrasvc | awk '{print $3}')
sudo docker rmi $image

present=$(rpm -qa | grep diaman | grep spektra | grep "${firstrpm}")
if [ "$present" != "" ]; then
	echo "REMOVING ${firstrpm} RPM in 10 seconds, cleanup spektra"
	echo "Installing spektra-${rpmnew}..."
	sleep 10

	sudo rpm -e diamanti-spektra-${firstrpm}.x86_64
	sleep 5

	sudo rpm -ivh ~/rpms/diamanti-spektra-${rpmnew}.x86_64.rpm
	echo "RPM INSTALLATION DONE"
	sleep 5

	init_spektra.sh
	sleep 5
	for i in {1..10}; do ~/sushil/GeneralScripts/useful_to_all/pull_all_failed_docker_images.sh ; done
	../useful_to_all/test.sh
fi
