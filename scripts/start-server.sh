#!/bin/bash
mkdir -p ${SERVER_DIR}/logs/steam
mkdir -p /home/steam/Steam
rm -rf /home/steam/Steam/logs
ln -sfn ${SERVER_DIR}/logs/steam /home/steam/Steam/logs

if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "[ERROR] SteamCMD not found, downloading..."
    wget -q -O /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
        || { echo "[ERROR] Failed to download SteamCMD"; exit 1; }
    tar -C "${STEAMCMD_DIR}" -xzf /tmp/steamcmd.tar.gz \
        || { echo "[ERROR] Failed to extract SteamCMD"; exit 1; }
    rm /tmp/steamcmd.tar.gz
fi

if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh +login anonymous +quit > /dev/null 2>&1 \
        || echo "[WARN] SteamCMD self-update failed"
else
    ${STEAMCMD_DIR}/steamcmd.sh +login ${USERNAME} ${PASSWRD} +quit > /dev/null 2>&1 \
        || echo "[WARN] SteamCMD self-update failed"
fi

if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit || { echo "[ERROR] Server update/validate failed"; exit 1; }
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit || { echo "[ERROR] Server update failed"; exit 1; }
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit || { echo "[ERROR] Server update/validate failed"; exit 1; }
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit || { echo "[ERROR] Server update failed"; exit 1; }
    fi
fi

export LD_LIBRARY_PATH="${SERVER_DIR}/linux64:${SERVER_DIR}/natives:${SERVER_DIR}:${LD_LIBRARY_PATH}"
export PATH="${SERVER_DIR}/jre64/bin:${PATH}"

cp /opt/scripts/ProjectZomboid64.json ${SERVER_DIR}/ProjectZomboid64.json \
    || { echo "[ERROR] Failed to copy ProjectZomboid64.json"; exit 1; }
cp /opt/scripts/ProjectZomboid32.json ${SERVER_DIR}/ProjectZomboid32.json \
    || { echo "[ERROR] Failed to copy ProjectZomboid32.json"; exit 1; }

if [ ! -d ${SERVER_DIR}/Zomboid ]; then
	cp -r /opt/config/cfg/Zomboid ${SERVER_DIR}/Zomboid \
		|| { echo "[ERROR] Failed to copy server config template"; exit 1; }
fi

find ${SERVER_DIR} -name "masterLog.0" -exec rm -f {} \; > /dev/null 2>&1
chmod -R ${DATA_PERM} /serverdata

cd ${SERVER_DIR}
screen -S PZ -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/ProjectZomboid64 -adminpassword ${ADMIN_PWD} ${GAME_PARAMS} \
    || { echo "[ERROR] Failed to start server"; exit 1; }
sleep 2
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0
tail -f ${SERVER_DIR}/masterLog.0