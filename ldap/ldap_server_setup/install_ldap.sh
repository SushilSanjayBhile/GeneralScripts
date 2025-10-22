#!/bin/bash

# Input domain (e.g., MyCompany) and suffix (e.g., COM)
DOMAIN_NAME="$1"
SUFFIX="$2"

if [ -z "$DOMAIN_NAME" ] || [ -z "$SUFFIX" ]; then
  echo "Usage: $0 <DomainName> <DomainSuffix>"
  exit 1
fi

echo "Installing OpenLDAP server and clients..."

# Install openldap clients and schema tools
sudo yum install -y openldap openldap-clients

# Install openldap-servers from CentOS Vault manually
cd /tmp
wget http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/Packages/openldap-servers-2.4.46-18.el8.x86_64.rpm
sudo rpm -ivh openldap-servers-2.4.46-18.el8.x86_64.rpm

# Start and enable slapd service
sudo systemctl enable slapd
sudo systemctl start slapd

echo "Loading core schemas..."
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

echo "Verifying inetOrgPerson schema loaded:"
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=schema,cn=config" dn | grep inetOrgPerson
