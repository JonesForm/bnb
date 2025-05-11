#!/bin/bash

# info for auto mount service
SCRIPT_PATH="/home/student/Documents/bnb/mount_public.share.sh"
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