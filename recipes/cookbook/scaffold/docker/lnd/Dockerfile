ARG LND_DOCKER_BUILDTIME_IMAGE
ARG LND_DOCKER_RUNTIME_IMAGE

FROM ${LND_DOCKER_BUILDTIME_IMAGE} as simverse_buildtime_lnd

#include BASE_DOCKERFILE_SNIPPET
#include BUILDTIME_DOCKERFILE_SNIPPET

ARG LND_REPO_PATH

WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
COPY "$LND_REPO_PATH" .

# force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# install dependencies and install/build lnd.
RUN make && make install

# ---------------------------------------------------------------------------------------------------------------------------

FROM ${LND_DOCKER_RUNTIME_IMAGE} as simverse_runtime_lnd

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

ARG LND_CONF_PATH

# copy the binaries and entrypoint from the builder image.
COPY --from=simverse_buildtime_lnd /go/bin/lncli /bin/
COPY --from=simverse_buildtime_lnd /go/bin/lnd /bin/

USER simnet

WORKDIR /home/simnet

COPY --chown=simnet "docker/lnd/home" "."
COPY --chown=simnet "$LND_CONF_PATH" "seed-lnd.conf"

RUN mkdir .lnd
