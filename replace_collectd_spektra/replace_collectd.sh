conffile=cluster.kubeconfig

pod=$(KUBECONFIG=$conffile kubectl get pods -n spektra-system | grep collectd | awk '{print $1}'); echo $pod
KUBECONFIG=$conffile timeout 2 kubectl delete pod -n spektra-system $pod

KUBECONFIG=$conffile kubectl -n spektra-system delete cm collectd-config
KUBECONFIG=$conffile kubectl -n spektra-system create configmap collectd-config \
	--from-file=collectd.conf --from-file=diamanti.py \
	--from-file=diamanti_types.db --from-file=types.db \
	--dry-run=client -o yaml | KUBECONFIG=$conffile kubectl apply -f -

KUBECONFIG=$conffile kubectl delete -f collectd_daemonset.yaml ; KUBECONFIG=$conffile kubectl create -f collectd_daemonset.yaml



watch KUBECONFIG=$conffile kubectl get pods -n spektra-system;
pod=$(KUBECONFIG=$conffile kubectl get pods -n spektra-system | grep collectd | awk '{print $1}'); KUBECONFIG=$conffile kubectl logs -n spektra-system -f $pod -c collectd-es
