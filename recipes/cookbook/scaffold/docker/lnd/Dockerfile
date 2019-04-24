FROM simverse/buildtime:local as simverse_buildtime_lnd

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

FROM simverse/runtime:local as simverse_runtime_lnd

ARG LND_CONF_PATH

# copy the binaries and entrypoint from the builder image.
COPY --from=simverse_buildtime_lnd /go/bin/lncli /bin/
COPY --from=simverse_buildtime_lnd /go/bin/lnd /bin/

USER simnet

WORKDIR /home/simnet

COPY "docker/lnd/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"

COPY "$LND_CONF_PATH" "/home/simnet/seed-lnd.conf"