FROM simverse_builder:local as builder_bitcoind

ARG BITCOIND_REPO_PATH

WORKDIR /root/build

COPY "$BITCOIND_REPO_PATH" .

COPY "docker/bitcoind/patches/issue-611.patch" .
RUN git apply issue-611.patch

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

FROM simverse_base:local as final_bitcoind

ARG BITCOIND_CONF_PATH

# copy the compiled binaries from the builder image
COPY --from=builder_bitcoind /usr/local/bin/bitcoin* /usr/local/bin/

# we also need to copy some relevant libraries over
COPY --from=builder_bitcoind /usr/lib/libboost* /usr/lib/
COPY --from=builder_bitcoind /usr/local/lib/libbitcoin* /usr/local/lib/

USER simnet

WORKDIR /home/simnet

COPY "docker/bitcoind/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/base/lib" "/home/simnet/lib"

COPY "$BITCOIND_CONF_PATH" "/home/simnet/seed-bitcoin.conf"
