FROM simverse_buildtime:local as simverse_buildtime_pre

WORKDIR /root/build

# we want to populate the module cache based on the go.{mod,sum} files.
COPY ./repos/btcd/go.mod .
COPY ./repos/btcd/go.sum .

# pre-cache deps
# see https://container-solutions.com/faster-builds-in-docker-with-go-1-11/
RUN go mod download

WORKDIR $GOPATH/src/github.com/btcsuite/btcd

# https://github.com/btcsuite/btcd#installation
COPY "repos/btcd" .
COPY "docker/btcd/patches/btcctl-regtest.patch" .
RUN git apply btcctl-regtest.patch
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse_runtime:local as simverse_runtime_pre

RUN apk add --no-cache python

# copy the compiled binaries from the builder image.
COPY --from=simverse_buildtime_pre /go/bin/gencerts /bin/

USER simnet

WORKDIR /home/simnet

COPY "docker/pre/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"
