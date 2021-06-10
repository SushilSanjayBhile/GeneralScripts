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

dctl -s 172.16.220.20 cluster create sol10 solserv10 --vip 172.16.220.230 --poddns sol10.sol.diamanti.com --storage-vlan 215 -p Diamanti@111
sleep 30s
dctl  -s 172.16.220.230 login -u admin -p Diamanti@111
dctl network create default -s 172.16.209.0/24 --start 172.16.209.2 --end 172.16.209.81  -g 172.16.209.1 -v 209 --set-default --host-network
