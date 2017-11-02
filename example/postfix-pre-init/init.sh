#!/bin/sh

# Show current configuration
echo -e "\n\e[1mCurrent configuration:\e[0m"

postconf "myhostname"
postconf "mydomain"
postconf "inet_interfaces"
postconf "mydestination"

# This will configure null client as shown on http://www.postfix.org/STANDARD_CONFIGURATION_README.html#null_client
postconf -e "myhostname=hostname.example.com"
postconf -e "mydomain=example.com"
postconf -e "inet_interfaces=loopback-only"
postconf -e "mydestination="

# Show new configuration
echo -e "\n\e[1mNew configuration:\e[0m"

postconf "myhostname"
postconf "mydomain"
postconf "inet_interfaces"
postconf "mydestination"