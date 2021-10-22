port=$(sudo rpm -qa | grep diamanti | grep spektra | grep -E "3.3|0.0")
if [ ! -z "$port" ]; then
	export port=5443
else
	export port=30011
fi

export DMCTL_SERVER=https://172.16.220.230:$port
export DMCTL_INSECURE_SKIP_VERIFY=true

# ---- Create tenant pepsi
dmctl -n speksys auth userpass login --username=admin --password=Diamanti@111     # Diamanti@111
dmctl tenant create pepsi --username=admin --password=Diamanti@111
dmctl tenant create coke --username=admin --password=Diamanti@111

kubectl create -f ~/spektra-sa.yaml
kubectl create -f ~/spektra-rbac.yaml

cluster_name=$(dctl cluster status | grep Name | awk '{print $3}')
rm ~/${cluster_name}.kubeconfig

filename=$(date '+%m%d%y_%H%M%S')
cat /usr/diamanti/spektra/deploy/clispecs/project/use_clusters.json | sed "s/scluster83/${filename}/g;s/kcluster85/${filename}/g" > ${filename}.json
dmctl project create proj_${filename} --username admin --use-clusters-file ./${filename}.json

/usr/bin/kubernetes_add_service_account_kubeconfig.sh spektra-service-account default ~/${cluster_name}.kubeconfig /tmp
#before adopting login to tenant or provide tenancy namespace
dmctl -n spektra/pepsi auth userpass login --username=admin --password=Diamanti@111

dmctl cluster attach --kubeconfig ~/${cluster_name}.kubeconfig --name ${cluster_name}
