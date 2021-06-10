dctl cluster destroy $(dctl cluster status | awk '/UUID/ {print $3}') -y
