FROM ubuntu:24.04@sha256:84e77dee7d1bc93fb029a45e3c6cb9d8aa4831ccfcc7103d36e876938d28895b

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
