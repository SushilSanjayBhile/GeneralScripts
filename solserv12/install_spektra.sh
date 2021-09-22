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

