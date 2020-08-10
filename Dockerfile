FROM ubuntu:18.04

# make apt non-interactive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y \
	&& apt-get install -qy --no-install-recommends apt-utils \
	&& apt-get install -qy --no-install-recommends \
		curl \
		wget \
		lsb-release \
		curl \
		wget \
		rsync \
		util-linux \
		psmisc \
		ca-certificates \
		dirmngr \
		gpg \
		patch \
		gpg-agent \
		libcap2-bin \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get autoremove

# install unifi video package
RUN wget -q -O - http://www.ubnt.com/downloads/unifi-video/apt-3.x/unifi-video.gpg.key | apt-key add - \
	&& echo "deb [arch=amd64] http://www.ubnt.com/downloads/unifi-video/apt-3.x $(lsb_release -c | awk '{print $2}') ubiquiti" | tee /etc/apt/sources.list.d/unifi-video.list \
	&& apt-get update -q -y \
	&& RUNLEVEL=1 apt-get install -q -y --no-install-recommends unifi-video \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get autoremove

# define volumes
VOLUME /var/lib/unifi-video
VOLUME /var/lib/unifi-video/logs

# RTMP, RTMPS & RTSP via the controller
EXPOSE 1935/tcp 7444/tcp 7447/tcp
# Inbound Camera Streams & Camera Management (NVR Side)
EXPOSE 6666/tcp 7442/tcp
# UVC-Micro Talkback (Camera Side)
EXPOSE 7004/udp
# HTTP & HTTPS Web UI + API
EXPOSE 7080/tcp 7443/tcp
# Video over HTTP & HTTPS
EXPOSE 7445/tcp 7446/tcp

# copy config
COPY system.properties /var/lib/unifi-video/

# patch
COPY unifi-video.patch /tmp
RUN patch -lN /usr/sbin/unifi-video /tmp/unifi-video.patch \
	&& rm /tmp/unifi-video.patch

# copy start script
COPY run.sh /
RUN chmod +x /run.sh

# start unifi-video service
CMD ["/run.sh"]
