dctl volume list | grep none | awk '{print $1}' | xargs -i dctl volume delete {} -y

