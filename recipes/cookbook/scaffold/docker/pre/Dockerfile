ARG PRE_DOCKER_BUILDTIME_IMAGE
ARG PRE_DOCKER_RUNTIME_IMAGE

FROM ${PRE_DOCKER_RUNTIME_IMAGE} as simverse_runtime_pre

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

USER simnet

WORKDIR /home/simnet

COPY "docker/pre/home" "/home/simnet/"

# replace symlink with actual target lib files
RUN rm lib
COPY "docker/_aux/runtime/lib" "/home/simnet/lib"

RUN mkdir certs
