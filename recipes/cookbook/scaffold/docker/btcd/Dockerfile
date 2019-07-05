ARG BTCD_DOCKER_BUILDTIME_IMAGE
ARG BTCD_DOCKER_RUNTIME_IMAGE

FROM ${BTCD_DOCKER_BUILDTIME_IMAGE} as simverse_buildtime_btcwallet

#include BASE_DOCKERFILE_SNIPPET
#include BUILDTIME_DOCKERFILE_SNIPPET

ARG BTCWALLET_REPO_PATH

WORKDIR /root/build

# we want to populate the module cache based on the go.{mod,sum} files.
COPY "$BTCWALLET_REPO_PATH/go.mod" .
COPY "$BTCWALLET_REPO_PATH/go.sum" .

# pre-cache deps
# see https://container-solutions.com/faster-builds-in-docker-with-go-1-11/
RUN go mod download

# https://github.com/btcsuite/btcwallet#installation-and-updating
WORKDIR $GOPATH/src/github.com/btcsuite/btcwallet

COPY "$BTCWALLET_REPO_PATH" .
COPY "docker/btcd/patches/simnet-as-regtest.patch" .
RUN git apply simnet-as-regtest.patch
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse/buildtime:local as simverse_buildtime_btcd

ARG BTCD_REPO_PATH

WORKDIR /root/build

# we want to populate the module cache based on the go.{mod,sum} files.
COPY "$BTCD_REPO_PATH/go.mod" .
COPY "$BTCD_REPO_PATH/go.sum" .

# pre-cache deps
# see https://container-solutions.com/faster-builds-in-docker-with-go-1-11/
RUN go mod download

WORKDIR $GOPATH/src/github.com/btcsuite/btcd

# https://github.com/btcsuite/btcd#installation
COPY "$BTCD_REPO_PATH" .
COPY "docker/btcd/patches/btcctl-regtest.patch" .
RUN git apply btcctl-regtest.patch
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${BTCD_DOCKER_RUNTIME_IMAGE} as simverse_runtime_btcd

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

ARG BTCD_CONF_PATH
ARG BTCWALLET_CONF_PATH

# copy the compiled binaries from the builder image.
COPY --from=simverse_buildtime_btcd /go/bin/addblock /bin/
COPY --from=simverse_buildtime_btcd /go/bin/btcctl /bin/
COPY --from=simverse_buildtime_btcd /go/bin/btcd /bin/
COPY --from=simverse_buildtime_btcd /go/bin/findcheckpoint /bin/
COPY --from=simverse_buildtime_btcd /go/bin/gencerts /bin/

COPY --from=simverse_buildtime_btcwallet /go/bin/btcwallet /bin/

USER simnet

WORKDIR /home/simnet

COPY --chown=simnet "docker/btcd/home" "/home/simnet/"
COPY --chown=simnet "$BTCD_CONF_PATH" "/home/simnet/seed-btcd.conf"
COPY --chown=simnet "$BTCWALLET_CONF_PATH" "/home/simnet/seed-btcwallet.conf"

RUN mkdir .btcd
RUN mkdir .btcwallet