FROM simverse_builder:local as builder_btcd

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
RUN GO111MODULE=on go install -v . ./cmd/...

# ---------------------------------------------------------------------------------------------------------------------------

FROM simverse_base:local as final

RUN apk add --no-cache python

# copy the compiled binaries from the builder image.
COPY --from=builder_btcd /go/bin/gencerts /bin/

WORKDIR /root

COPY "docker/pre/home" "/root/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/base/lib" "/root/lib"
