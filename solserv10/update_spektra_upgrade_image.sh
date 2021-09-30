SPEKSVCCNTL_IMG=upgrade_spektra23
sudo sed -i'' -e 's@spektra\.diamanti\.io\/version: .*upgrade_spektra.*@spektra\.diamanti\.io\/version: '"${SPEKSVCCNTL_IMG}"'@' /usr/diamanti/spektra/deploy/spektra_install.yaml
sudo sed -i'' -e 's@image: .*upgrade_spektra.*@spektra\.diamanti\.io\/version: '"${SPEKSVCCNTL_IMG}"'@' /usr/diamanti/spektra/deploy/spektra_install.yaml
