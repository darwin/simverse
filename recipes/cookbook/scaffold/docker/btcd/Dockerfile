FROM simverse_builder:local as builder_btcwallet

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
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse_builder:local as builder_btcd

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
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse_base:local as final

ARG BTCD_CONF_PATH
ARG BTCWALLET_CONF_PATH

# copy the compiled binaries from the builder image.
COPY --from=builder_btcd /go/bin/addblock /bin/
COPY --from=builder_btcd /go/bin/btcctl /bin/
COPY --from=builder_btcd /go/bin/btcd /bin/
COPY --from=builder_btcd /go/bin/findcheckpoint /bin/
COPY --from=builder_btcd /go/bin/gencerts /bin/

COPY --from=builder_btcwallet /go/bin/btcwallet /bin/

USER simnet

WORKDIR /home/simnet

COPY "docker/btcd/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/base/lib" "/home/simnet/lib"

COPY "$BTCD_CONF_PATH" "/home/simnet/seed-btcd.conf"
COPY "$BTCWALLET_CONF_PATH" "/home/simnet/seed-btcwallet.conf"