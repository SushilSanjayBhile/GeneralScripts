cleanup_spektra.sh
dctl -s 172.16.220.103 login -u admin -p Diamanti@1111 -n spektra-system

timeout 30 cleanup_spektra.sh
dctl -s 172.16.220.103 login -u admin -p Diamanti@1111 -n spektra-system

kubectl delete namespace spektra-system spektra-pepsi-project-default-project spektra-pepsi-project-default-system-project --force --grace-period=0
