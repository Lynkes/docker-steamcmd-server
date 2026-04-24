FROM debian:bookworm-slim

# SteamCMD requires 32-bit libraries on 64-bit hosts
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        lib32gcc-s1 \
        wget \
 && rm -rf /var/lib/apt/lists/*

# Runtime environment — override these via --env or Docker Compose
ENV STEAMCMD_DIR=/opt/steamcmd \
    SERVER_DIR=/serverdata \
    GAME_ID="" \
    GAME_BRANCH="" \
    GAME_LAUNCH_CMD="" \
    GAME_PARAMS="" \
    GAME_PARAMS_EXTRA="" \
    VALIDATE="" \
    USERNAME="" \
    PASSWRD="" \
    ADMIN_PWD="" \
    PUID=1000 \
    PGID=1000

# Download SteamCMD at build time; create steam user and data dirs
RUN useradd -m -s /bin/bash steam \
 && mkdir -p "${STEAMCMD_DIR}" "${SERVER_DIR}" \
 && wget -qO /tmp/steamcmd.tar.gz \
        https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -C "${STEAMCMD_DIR}" -xzf /tmp/steamcmd.tar.gz \
 && rm /tmp/steamcmd.tar.gz \
 && chown -R steam:steam "${STEAMCMD_DIR}" "${SERVER_DIR}"

COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

ENTRYPOINT ["/opt/scripts/start.sh"]