ARG PRE_DOCKER_BUILDTIME_IMAGE
ARG PRE_DOCKER_RUNTIME_IMAGE

FROM ${PRE_DOCKER_RUNTIME_IMAGE} as simverse_runtime_pre

#include BASE_DOCKERFILE_SNIPPET
#include RUNTIME_DOCKERFILE_SNIPPET

USER simnet

WORKDIR /home/simnet

COPY "docker/pre/home" "/home/simnet/"

RUN mkdir certs
