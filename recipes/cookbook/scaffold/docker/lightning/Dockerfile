# see https://medium.com/@tonistiigi/advanced-multi-stage-build-patterns-6f741b852fae
ARG RELEVANT_BITCOIND_IMAGE

# modelled after https://github.com/ElementsProject/lightning/blob/master/Dockerfile
FROM simverse/buildtime:local as simverse_buildtime_lightning

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
sqlite-dev \
wget \
git \
file \
gnupg \
swig \
zlib-dev

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

ARG LIGHTNING_DEVELOPER_FLAG=0
RUN ./configure --prefix=/tmp/lightning_install
ARG LIGHTNING_VALGRIND_FLAG=0

RUN make DEVELOPER=${LIGHTNING_DEVELOPER_FLAG} VALGRIND=${LIGHTNING_VALGRIND_FLAG}

RUN make install

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${RELEVANT_BITCOIND_IMAGE} as simverse_runtime_bitcoind

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse/runtime:local as simverse_runtime_lightning

RUN apk add --no-cache --update \
gmp-dev \
sqlite-dev \
inotify-tools \
socat \
bash \
zlib-dev \
tini

ENV GLIBC_VERSION 2.27-r0
ENV GLIBC_SHA256 938bceae3b83c53e7fa9cc4135ce45e04aae99256c5e74cf186c794b97473bc7
ENV GLIBCBIN_SHA256 3a87874e57b9d92e223f3e90356aaea994af67fb76b71bb72abfb809e948d0d6
# Download and install glibc (https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile)
RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  echo "$GLIBC_SHA256  glibc.apk" | sha256sum -c - && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  echo "$GLIBCBIN_SHA256  glibc-bin.apk" | sha256sum -c - && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  apk del curl && \
  rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

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

COPY "docker/lightning/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"

COPY "$LIGHTNING_CONF_PATH" "/home/simnet/seed-config"

RUN mkdir .lightning