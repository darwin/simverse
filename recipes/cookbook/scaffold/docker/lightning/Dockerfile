# see https://medium.com/@tonistiigi/advanced-multi-stage-build-patterns-6f741b852fae
ARG LIGHTNING_DOCKER_BUILDTIME_IMAGE
ARG LIGHTNING_DOCKER_RUNTIME_IMAGE
ARG RELEVANT_BITCOIND_IMAGE

# modelled after https://github.com/ElementsProject/lightning/blob/master/Dockerfile
FROM ${LIGHTNING_DOCKER_BUILDTIME_IMAGE} as simverse_buildtime_lightning

#include BASE_DOCKERFILE_SNIPPET
#include BUILDTIME_DOCKERFILE_SNIPPET

RUN apk add --no-cache --update \
ca-certificates \
autoconf \
automake \
build-base \
libressl \
libtool \
gmp-dev \
python \
python-dev \
python3 \
py3-mako \
sqlite-dev \
net-tools \
wget \
git \
file \
gnupg \
swig \
zlib-dev \
libsodium \
gettext

ARG LIGHTNING_REPO_PATH

WORKDIR /root/build

COPY "$LIGHTNING_REPO_PATH" .

# lower optimizations for faster builds
#ARG CFLAGS=""
#ARG CXXFLAGS="$CFLAGS"
ARG MAKEFLAGS="-j4"

#ENV CFLAGS="$CFLAGS"
#ENV CXXFLAGS="$CXXFLAGS"
ENV MAKEFLAGS="$MAKEFLAGS"

COPY "docker/lightning/patches/unknown-version-fallback.patch" .
RUN git apply unknown-version-fallback.patch

COPY "docker/lightning/patches/disable-shadow-routing.patch" .
RUN git apply disable-shadow-routing.patch

COPY "docker/lightning/patches/docker-entrypoint.patch" .
RUN git apply docker-entrypoint.patch

ARG LIGHTNING_DEVELOPER_FLAG=0
ARG LIGHTNING_VALGRIND_FLAG=0
ARG LIGHTNING_CONFIGURE_OPTS=""

RUN pip3 install --upgrade pip
RUN pip3 install mako mistune==0.8.4 mrkd

RUN ./configure --prefix=/tmp/lightning_install ${LIGHTNING_CONFIGURE_OPTS}

RUN make DEVELOPER=${LIGHTNING_DEVELOPER_FLAG} VALGRIND=${LIGHTNING_VALGRIND_FLAG}

RUN make install

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${RELEVANT_BITCOIND_IMAGE} as simverse_runtime_bitcoind

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${LIGHTNING_DOCKER_RUNTIME_IMAGE} as simverse_runtime_lightning

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

RUN apk add --no-cache --update \
gmp-dev \
sqlite-dev \
inotify-tools \
socat \
bash \
zlib-dev \
tini 

# ADDED FOR RUNNING PYTHON PLUGINS
# BEGIN
RUN apk add --no-cache --update \
python3-dev \
py3-numpy \
lapack
# END

ARG LIGHTNING_CONF_PATH

# copy the binaries and entrypoint from the builder image.
COPY --from=simverse_buildtime_lightning /tmp/lightning_install/ /usr/local/

# copy some binaries from the bitcoind image
COPY --from=simverse_runtime_bitcoind /usr/local/bin/bitcoin-cli /usr/local/bin/
# we also need to copy some relevant libraries over
COPY --from=simverse_runtime_bitcoind /usr/lib/libboost* /usr/lib/

USER simnet

WORKDIR /home/simnet

ENV LIGHTNINGD_DATA=/home/simnet/.lightning
ENV LIGHTNINGD_NETWORK=regtest
# we need to place lightning-rpc outside volumes because of socket path limits (in docker)
# see https://github.com/moby/moby/issues/23545
ENV LIGHTNINGD_RPC_DIR_SIMVERSE=/tmp/lightningd-rpc
RUN mkdir -p "$LIGHTNINGD_RPC_DIR_SIMVERSE"

COPY --chown=simnet "docker/lightning/home" "."
COPY --chown=simnet --from=simverse_buildtime_lightning /root/build/tools/docker-entrypoint.sh lightning-docker-entrypoint.sh
COPY --chown=simnet "$LIGHTNING_CONF_PATH" "seed-config"
