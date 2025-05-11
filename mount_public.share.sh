#!/bin/bash

# --- Configuration ---
SERVER="\\BPDC01"
SHARE="PublicShare"
MOUNT_POINT="/mnt/PublicShare" # You can change this if needed
AD_USER="${USER}@bigpurple.com" # Uses the currently logged-in user's AD principal

# --- Install Necessary Packages ---
echo "Installing keyutils (if not already installed)..."
sudo dnf install -y keyutils

# --- Ensure Mount Point Exists ---
echo "Creating mount point: ${MOUNT_POINT}"
sudo mkdir -p "${MOUNT_POINT}"

# --- Check for Kerberos Ticket ---
echo "Checking for Kerberos ticket for ${AD_USER}..."
klist -s | grep "Kerberos 5 ticket cache" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "No valid Kerberos ticket found for ${AD_USER}. Please ensure you are logged in with an AD account or run 'kinit ${AD_USER}'."
  exit 1
fi

# --- Mount the Share ---
echo "Mounting the share using Kerberos..."
sudo mount -t cifs -o sec=krb5,username="${AD_USER}" "${SERVER}/${SHARE}" "${MOUNT_POINT}"

if [ $? -eq 0 ]; then
  echo "Successfully mounted ${SERVER}/${SHARE} to ${MOUNT_POINT}"
else
  echo "Failed to mount the share. Check the output for errors."
  exit 1
fi

exit 0