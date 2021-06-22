kubectl describe pod -A | grep -i "failed to pull" | cut -d'"' -f 2 | xargs -i sudo docker pull {}
