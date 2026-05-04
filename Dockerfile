FROM ghcr.io/graalvm/graalvm-community:25.0.2 AS graalvm
RUN cp -r $JAVA_HOME /graalvm-export

FROM debian:bookworm-slim


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

ENV JAVA_HOME="/opt/graalvm"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_ID=""
ENV GAME_PARAMS=""
ENV GAME_PARAMS_EXTRA=""
ENV ADMIN_PWD="adminDocker"
ENV GAME_PORT=16261
ENV VALIDATE=""
ENV UMASK=022
ENV PUID=1000
ENV PGID=1000
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
 && chown -R steam:steam "${STEAMCMD_DIR}" "${DATA_DIR}"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
ADD /config/ /opt/config/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]