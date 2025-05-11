#!/bin/bash

# Domain information
DOMAIN="bigpurple.com"
JOIN_USER="administrator"
ADMIN_PASSWORD="superw1n_user"
COMPUTER_OU="OU=BP_Computers,DC=bigpurple,DC=com"

# Packages incase not installed
echo "Installing required packages..."
sudo dnf install -y realmd sssd oddjob oddjob-mkhomedir adcli samba-common-tools krb5-workstation

# Discover the server
echo "Discovering Domain..."
realm discover "${DOMAIN}"

# Join the Domain 
echo "Joining the domain"
echo "${ADMIN_PASSWORD}" | sudo realm join --user="${JOIN_USER}" --computer-ou="${COMPUTER_OU}" "${DOMAIN}"

if [ $? -eq 0 ]; then
  echo "Successfully joined the domain: ${DOMAIN} and placed in OU: ${COMPUTER_OU}"

  # enable authentication
  echo "Configuring authentication..."
  sudo authselect select winbind -w --force

  echo "joined ${DOMAIN}"
else
  echo "Failed"
  exit 1
fi

exit 0