FROM ubuntu:23.10@sha256:2c12b887bd41265d2a3a5e993060c9da28dfc7eaab138c908aec196e087a3c86

# Build command
# time DOCKER_BUILDKIT=0 docker build -t pia-wg . -f Dockerfile

ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

COPY . .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3-pip git qrencode wireguard-tools && \
	python3 -m pip install --no-cache-dir --upgrade pip && \
	pip3 install --no-cache-dir -r requirements.txt && \
	apt-get purge -y git && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pia-wg"
LABEL org.opencontainers.image.description="A WireGuard configuration utility for Private Internet Access"

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["/entrypoint.sh"]
