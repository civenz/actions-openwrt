#!/bin/bash

LOG_FILE='/tmp/ngrok.log'

curl -fsSL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip -o ngrok.zip
unzip ngrok.zip
chmod +x ngrok
sudo mv ngrok /usr/local/bin

rm -f ngrok.zip
rm -f ${LOG_FILE}

echo -e "$SSH_PASSWORD\n$SSH_PASSWORD" | sudo passwd "$USER"


screen -dmS ngrok \
    ngrok tcp 22 \
    --log "${LOG_FILE}" \
    --authtoken "${NGROK_TOKEN}" \
    --region "${NGROK_REGION:-us}"


while ((${SECONDS_LEFT:=10} > 0)); do
    echo -e "${INFO} Please wait ${SECONDS_LEFT}s ..."
    sleep 1
    SECONDS_LEFT=$((${SECONDS_LEFT} - 1))
done


ERRORS_LOG=$(grep "command failed" ${LOG_FILE})


if [[ -e "${LOG_FILE}" && -z "${ERRORS_LOG}" ]]; then
  echo ""
  echo "=========================================="
  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="
else
  echo "$HAS_ERRORS"
  exit 4
fi
