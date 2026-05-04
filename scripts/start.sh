#!/bin/bash
usermod -u ${PUID} ${USER} || echo "[ERROR] Failed to set PUID ${PUID}"
groupmod -g ${PGID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${PGID} ${USER} || echo "[ERROR] Failed to set PGID ${PGID}"
umask ${UMASK}

_launch_script="/opt/scripts/start-server.sh"

if [ -f "${SERVER_DIR}/start-user.sh" ]; then
    if chmod +x "${SERVER_DIR}/start-user.sh"; then
        _launch_script="${SERVER_DIR}/start-user.sh"
    else
        echo "[ERROR] Failed to chmod start-user.sh, falling back to start-server.sh"
    fi
fi

chown -R root:${PGID} /opt/scripts || echo "[ERROR] Failed to chown /opt/scripts"
chmod -R 750 /opt/scripts
chown -R ${PUID}:${PGID} ${DATA_DIR} || echo "[ERROR] Failed to chown ${DATA_DIR}"

term_handler() {
	kill -SIGINT $(pidof ProjectZomboid64)
	tail --pid=$(pidof ProjectZomboid64) -f 2>/dev/null
	sleep 0.5
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "${_launch_script}" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done