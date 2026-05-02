#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
echo "---Setting up Environment---"
export LD_LIBRARY_PATH="${SERVER_DIR}/linux64:${SERVER_DIR}/natives:${SERVER_DIR}:${LD_LIBRARY_PATH}"
echo "---Redirecting game JRE to GraalVM---"
ZULU_HOME=$(dirname $(dirname $(readlink -f $(which java))))
if [ -d "${SERVER_DIR}/jre64" ] && [ ! -L "${SERVER_DIR}/jre64" ]; then
	mv "${SERVER_DIR}/jre64" "${SERVER_DIR}/jre64.bak"
fi
if [ ! -L "${SERVER_DIR}/jre64" ]; then
	ln -s "${ZULU_HOME}" "${SERVER_DIR}/jre64"
fi
echo "---Using Java: $(java -version 2>&1 | head -1)---"
echo "---Copying JVM launcher configuration---"
cp /opt/scripts/ProjectZomboid64.json ${SERVER_DIR}/ProjectZomboid64.json
cp /opt/scripts/ProjectZomboid32.json ${SERVER_DIR}/ProjectZomboid32.json
echo "---Looking for server configuration file---"
if [ ! -d ${SERVER_DIR}/Zomboid ]; then
	echo "---No server configuration found, copying template from config folder---"
	cp -r /opt/config/cfg/Zomboid ${SERVER_DIR}/Zomboid
	echo "---Successfully copied server configuration files---"
else
	echo "---Server configuration files found!---"
fi

echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.0" -exec rm -f {} \; > /dev/null 2>&1
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S PZ -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/ProjectZomboid64 -adminpassword ${ADMIN_PWD} ${GAME_PARAMS}
sleep 2
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0