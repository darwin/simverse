ARG BITCOIND_DOCKER_BUILDTIME_IMAGE
ARG BITCOIND_DOCKER_RUNTIME_IMAGE

FROM ${BITCOIND_DOCKER_BUILDTIME_IMAGE} as simverse_buildtime_bitcoind

#include BASE_DOCKERFILE_SNIPPET
#include BUILDTIME_DOCKERFILE_SNIPPET

ARG BITCOIND_REPO_PATH

WORKDIR /root/build

COPY "$BITCOIND_REPO_PATH" .
# lower optimizations for faster builds
ARG CFLAGS=""
ARG CXXFLAGS="$CFLAGS"
ARG MAKEFLAGS="-j4"

ENV CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV MAKEFLAGS="$MAKEFLAGS"

RUN ./autogen.sh

ARG BITCOIND_CONFIGURE_FLAGS="--without-gui --disable-tests --disable-bench --with-incompatible-bdb"
RUN ./configure $BITCOIND_CONFIGURE_FLAGS

RUN make

RUN make install

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${BITCOIND_DOCKER_RUNTIME_IMAGE} as simverse_runtime_bitcoind

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

ARG BITCOIND_CONF_PATH

# copy the compiled binaries from the builder image
COPY --from=simverse_buildtime_bitcoind /usr/local/bin/bitcoin* /usr/local/bin/

# we also need to copy some relevant libraries over
COPY --from=simverse_buildtime_bitcoind /usr/lib/libboost* /usr/lib/
COPY --from=simverse_buildtime_bitcoind /usr/local/lib/libbitcoin* /usr/local/lib/

USER simnet

WORKDIR /home/simnet

COPY --chown=simnet "docker/bitcoind/home" "."
COPY --chown=simnet "$BITCOIND_CONF_PATH" "seed-bitcoin.conf"

RUN mkdir .bitcoin
