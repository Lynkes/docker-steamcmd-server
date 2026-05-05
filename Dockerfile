FROM ghcr.io/graalvm/graalvm-community:25.0.2 AS graalvm
RUN cp -r $JAVA_HOME /graalvm-export
FROM debian:trixie-slim

ARG GRAALVM_VERSION="25.0.2"

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        lib32gcc-s1 \
        screen \
        wget \
 && rm -rf /var/lib/apt/lists/*
COPY --from=graalvm /graalvm-export /opt/graalvm

#Set environment variables
ENV JAVA_HOME="/opt/graalvm"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV STEAMCMD_DIR="/serverdata/steamcmd"
ENV SERVER_DIR="/serverdata/serverfiles"
#ENV GAME_ID="380870 -beta unstable" #B42.17+ use  "380870 -beta unstable"
ENV GAME_ID="380870"
#ENV GAME_ID="380870" Use this for stable branch
ENV GAME_PARAMS=""
ENV GAME_PARAMS_EXTRA=""
ENV ADMIN_PWD="adminDocker"
ENV VALIDATE=""
ENV UMASK=022
ENV PUID=568
ENV PGID=568
ENV USERNAME=""
ENV PASSWRD=""
ENV USER="steam"
ENV DATA_PERM=770

RUN useradd -m -s /bin/bash steam \
 && mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}" \
 && wget -qO /tmp/steamcmd.tar.gz \
        https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -C "${STEAMCMD_DIR}" -xzf /tmp/steamcmd.tar.gz \
 && rm /tmp/steamcmd.tar.gz \
 && chown -R steam:steam /serverdata
ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
ADD /config/ /opt/config/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]