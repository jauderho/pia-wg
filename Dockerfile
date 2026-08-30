FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

# Build command
# time DOCKER_BUILDKIT=0 docker build -t pia-wg . -f Dockerfile

ARG DEBIAN_FRONTEND=noninteractive

# uv resolves the dependencies from uv.lock, so the image needs no pip and no
# system Python. Both the uv image and the interpreter it fetches are pinned.
COPY --from=ghcr.io/astral-sh/uv:0.12.7@sha256:95f2aa1fe59274951cfe9b0cbc7972e879ff1004bc8945d130a32eb0dbd85945 /uv /uvx /usr/local/bin/

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
ENV UV_PYTHON_INSTALL_DIR=/opt/python
ENV UV_NO_CACHE=1

COPY . .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ca-certificates qrencode wireguard-tools && \
	uv sync --frozen --no-dev && \
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
