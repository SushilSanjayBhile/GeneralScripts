cleanup_spektra.sh
login

timeout 30 cleanup_spektra.sh
login

kubectl delete namespace spektra-system spektra-pepsi-project-default-project spektra-pepsi-project-default-system-project --force --grace-period=0
