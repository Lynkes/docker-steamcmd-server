FROM ghcr.io/graalvm/graalvm-community:25.0.2 AS graalvm

FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-steamcmd-server"

ARG GRAALVM_VERSION="25.0.2"

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y install --no-install-recommends \
		lib32gcc-s1 \
		screen && \
	rm -rf /var/lib/apt/lists/*

COPY --from=graalvm /usr/lib/jvm/graalvm-community-java25 /opt/graalvm

ENV JAVA_HOME="/opt/graalvm"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_ID="template"
ENV GAME_NAME="template"
ENV GAME_PARAMS="template"
ENV ADMIN_PWD="adminDocker"
ENV GAME_PORT=27015
ENV VALIDATE=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USERNAME=""
ENV PASSWRD=""
ENV USER="steam"
ENV DATA_PERM=770

RUN mkdir -p $DATA_DIR && \
	mkdir -p $STEAMCMD_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $SERVER_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
ADD /config/ /opt/config/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]