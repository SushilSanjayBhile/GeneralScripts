if [ $# -eq 1 ] && [ $1 == "reboot" ]
then
	sed -i 's/DIAMANTI_MIN_NODES=--min-nodes=3/DIAMANTI_MIN_NODES=--min-nodes=1/g' /etc/diamanti/armada.conf
	sed -i 's/DIAMANTI_QUORUM_SIZE=--quorum-size=3/DIAMANTI_QUORUM_SIZE=--quorum-size=1/g' /etc/diamanti/armada.conf
	cat /etc/diamanti/armada.conf

	echo "rebooting"
	sleep 5
	sudo reboot
else
	echo "no reboot"
fi

dctl -s 172.16.220.24 cluster create sol12 solserv12 --vip 172.16.220.103 --poddns sol12.sol.diamanti.com --storage-vlan 215 -p Diamanti@1111
sleep 30
dctl  -s 172.16.220.103 login -u admin -p Diamanti@1111
sleep 3
dctl network create default -s 172.16.209.0/24 --start 172.16.209.162 --end 172.16.209.241 -g 172.16.209.1 -v 209 --set-default --host-network
sleep 8
while [ 1 ]; do echo; kubectl get pod --all-namespaces | grep Pending; if [ $? -ne 0 ]; then break; echo; fi; sleep 3; done
