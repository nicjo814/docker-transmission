FROM lsiobase/alpine.python
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy local files
COPY root/ /

# install packages and set file exec
RUN \
 apk add --no-cache \
	curl \
	jq \
	transmission-cli \
	transmission-daemon && \
 chmod +x /usr/bin/socket-server.py && \
 chmod +x /usr/bin/bind-iface.sh

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /downloads /watch
