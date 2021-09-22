dctl -s 172.16.220.103 login -u admin -p Diamanti@1111 -n spektra-system
export DMCTL_SERVER=https://172.16.220.103:30011
#export DMCTL_SERVER=https://172.16.220.103:5443
export DMCTL_INSECURE_SKIP_VERIFY=true

# ---- Create tenant pepsi
dmctl -n speksys auth userpass login --username=admin --password=Diamanti@111     # Diamanti@111
sleep 3
dmctl tenant create pepsi --username=admin --password=Diamanti@111
sleep 1

kubectl create -f ~/spektra-sa.yaml
sleep 1
kubectl create -f ~/spektra-rbac.yaml
sleep 1

/usr/bin/kubernetes_add_service_account_kubeconfig.sh spektra-service-account default ~/sol12.kubeconfig /tmp 
sleep 3
#before adopting login to tenant or provide tenancy namespace
dmctl -n spektra/pepsi auth userpass login --username=admin --password=Diamanti@111
sleep 3

dmctl cluster attach --kubeconfig ~/sol12.kubeconfig --name sol12
