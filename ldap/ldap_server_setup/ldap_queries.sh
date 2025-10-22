#!/bin/bash

DOMAIN="MyCompany"
SUFFIX="COM"

# List all users
ldapsearch -x -b "ou=People,dc=$DOMAIN,dc=$SUFFIX" "(objectClass=inetOrgPerson)"

# Show only usernames
ldapsearch -x -b "ou=People,dc=$DOMAIN,dc=$SUFFIX" "(objectClass=inetOrgPerson)" uid

# Show full tree
ldapsearch -x -b "dc=$DOMAIN,dc=$SUFFIX" "(objectClass=*)"

# Show loaded schemas
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=schema,cn=config" dn

# Show server databases
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=config" dn | grep olcDatabase

# Get inetOrgPerson schema
sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "cn=inetorgperson,cn=schema,cn=config"

# Server capabilities
ldapsearch -x -s base -b "" supportedSASLMechanisms namingContexts
