a=0

dctl -s 172.16.220.103 login -u admin -p Diamanti@1111 -n spektra-system

while [ 1 ]; do
	while [ 1 ]; do echo "Waiting for pods to be in Running state for 2 minutes..."; kubectl get pods -A --no-headers | awk '{print $6}'  | grep -v m | grep -v h | grep -v d | grep -v vault > /dev/null; if [ $? -ne 0 ]; then a=$((a+1)); break; echo; fi; sleep 3; done
	echo "this is a" $a

	while [ 1 ]; do echo; kubectl get pods -A | grep -v vault | awk '{print $3}' | grep 0; if [ $? -ne 0 ]; then a=$((a+1)); break; echo; fi; sleep 3; done

	echo "this is a" $a

	if [ "$a" == "2" ]; then
		break
	fi
done
