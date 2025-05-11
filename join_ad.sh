#!/bin/bash

# --- Configuration ---
DOMAIN="bigpurple.com"
JOIN_USER="administrator"
ADMIN_PASSWORD="superw1n_user"
COMPUTER_OU="OU=BP_Computers,DC=bigpurple,DC=com"

# --- Install Necessary Packages ---
echo "Installing required packages..."
sudo dnf install -y realmd sssd oddjob oddjob-mkhomedir adcli samba-common-tools krb5-workstation

# --- Discover Realm ---
echo "Discovering realm..."
realm discover "${DOMAIN}"

# --- Join the Domain ---
echo "Joining the domain and specifying the OU..."
echo "${ADMIN_PASSWORD}" | sudo realm join --user="${JOIN_USER}" --computer-ou="${COMPUTER_OU}" "${DOMAIN}"

if [ $? -eq 0 ]; then
  echo "Successfully joined the domain: ${DOMAIN} and placed in OU: ${COMPUTER_OU}"

  # --- Configure Authentication ---
  echo "Configuring authentication..."
  sudo authselect select winbind -w --force

  # --- Enable Home Directory Creation ---
  echo "Enabling automatic home directory creation..."
  sudo systemctl enable --now oddjobd oddjob-mkhomedird

  echo "Fedora successfully joined to ${DOMAIN} and configured for AD login."
else
  echo "Failed to join the domain. Check the output for errors."
  exit 1
fi

exit 0