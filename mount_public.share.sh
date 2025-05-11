#!/bin/bash

# mount information
SERVER="\\BPDC01"
SHARE="PublicShare"
MOUNT_POINT="/mnt/PublicShare" # You can change this if needed
AD_USER="${USER}@bigpurple.com" # Uses the currently logged-in user's AD principal

# install keyutils if not installed
echo "Installing keyutils"
sudo dnf install -y keyutils

# make mount point
echo "Creating mount point: ${MOUNT_POINT}"
sudo mkdir -p "${MOUNT_POINT}"

# check for a kerberos ticket
echo "Checking for Kerberos ticket for ${AD_USER}..."
klist -s | grep "Kerberos 5 ticket cache" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "No valid Kerberos ticket found for ${AD_USER}. Please ensure you are logged in with an AD account or run 'kinit ${AD_USER}'."
  exit 1
fi

# mount the share location
echo "Mounting the share using Kerberos..."
sudo mount -t cifs -o sec=krb5,username="${AD_USER}" "${SERVER}/${SHARE}" "${MOUNT_POINT}"

if [ $? -eq 0 ]; then
  echo "Successfully mounted ${SERVER}/${SHARE} to ${MOUNT_POINT}"
else
  echo "Failed to mount"
  exit 1
fi

# info for auto mount service
SCRIPT_PATH="/home/student/Documents/bnb/mount_public_share.sh"
SERVICE_NAME="mount-public-all.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

#  Check if the script exists 
if [ ! -f "${SCRIPT_PATH}" ]; then
  echo "Error: Script not found at ${SCRIPT_PATH}"
  exit 1
fi

#  Create the system service file 
cat <<EOF > "${SERVICE_FILE}"
[Unit]
Description=Mount Public Share for All Users
After=network-online.target
Requires=network-online.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH}
User=root
Group=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "System service file '${SERVICE_FILE}' created."

#  Make sure its executable
sudo chmod +x "${SCRIPT_PATH}"
echo "Script '${SCRIPT_PATH}' ensured to be executable."

#  Enable the system service 
sudo systemctl enable "${SERVICE_NAME}"
echo "System service '${SERVICE_NAME}' enabled."

#  Start the system service (optional, for immediate effect)
read -p "Do you want to start the service now? (y/N): " start_now
if [[ "${start_now}" == "y" || "${start_now}" == "Y" ]]; then
  sudo systemctl start "${SERVICE_NAME}"
  if [ $? -eq 0 ]; then
    echo "System service '${SERVICE_NAME}' started."
  else
    echo "Error starting system service '${SERVICE_NAME}'."
  fi
fi

echo "Script completed."
exit 0