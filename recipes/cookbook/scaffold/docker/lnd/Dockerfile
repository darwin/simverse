FROM simverse_builder:local as builder

ARG LND_REPO_PATH

WORKDIR /root/build

# we want to populate the module cache based on the go.{mod,sum} files.
COPY "$LND_REPO_PATH/go.mod" .
COPY "$LND_REPO_PATH/go.sum" .
COPY "$LND_REPO_PATH/ticker" ticker
COPY "$LND_REPO_PATH/queue" queue

# pre-cache deps
# see https://container-solutions.com/faster-builds-in-docker-with-go-1-11/
RUN go mod download

WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
COPY "$LND_REPO_PATH" .

# force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# install dependencies and install/build lnd.
RUN make && make install

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse_base:local as final

ARG LND_CONF_PATH

# copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/lnd /bin/

WORKDIR "/root"

COPY "docker/lnd/home" "/root/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/base/lib" "/root/lib"

COPY "$LND_CONF_PATH" "/root/seed-lnd.conf"