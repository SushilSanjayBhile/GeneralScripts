dctl -s 172.16.220.230 login -q -u admin -p Diamanti@111 -n spektra-system

port=$(sudo rpm -qa | grep diamanti | grep spektra | grep -E "3.3|0.0")
if [ ! -z "$port" ]; then
	echo "5443"
else
	echo "30011"
fi

exit

export DMCTL_SERVER=https://172.16.220.230:30011
export DMCTL_SERVER=https://172.16.220.230:5443
export DMCTL_INSECURE_SKIP_VERIFY=true

# ---- Create tenant pepsi
dmctl -n speksys auth userpass login --username=admin --password=Diamanti@111     # Diamanti@111
dmctl tenant create pepsi --username=admin --password=Diamanti@111

kubectl create -f ~/spektra-sa.yaml
kubectl create -f ~/spektra-rbac.yaml

/usr/bin/kubernetes_add_service_account_kubeconfig.sh spektra-service-account default ~/sol10.kubeconfig /tmp 
#before adopting login to tenant or provide tenancy namespace
dmctl -n spektra/pepsi auth userpass login --username=admin --password=Diamanti@111

dmctl cluster attach --kubeconfig ~/sol10.kubeconfig --name sol10
