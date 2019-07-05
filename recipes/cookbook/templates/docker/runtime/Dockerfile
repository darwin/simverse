# >>> runtime snippet >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# this is a Dockerfile snippet used in docker containers for runtime

ARG SIMVERSE_HOST_UID
ARG SIMVERSE_HOST_GID

RUN apk add --no-cache --update \
libzmq \
libevent \
db \
db-c++ \
libressl \
jq \
tini \
tree

# TODO: move this into a special snippet to provide go debugging support
# RUN go get -u github.com/go-delve/delve/cmd/dlv
# RUN dlv version

# we want to prepare simnet user and run services under it
# our main reason is to have docker _volumes written with host-friendly permissions
# see https://dille.name/blog/2018/07/16/handling-file-permissions-when-writing-to-volumes-from-docker-containers/

# if the GID is already taken, create group without forcing external SIMVERSE_HOST_GID
RUN if getent group $SIMVERSE_HOST_GID > /dev/null 2>&1; \
      then addgroup simnet; \
      else addgroup -g $SIMVERSE_HOST_GID simnet; \
    fi

# if the GID is already taken, create group without forcing external SIMVERSE_HOST_GID
RUN if id -u $SIMVERSE_HOST_UID > /dev/null 2>&1; \
      then adduser -D -h /home/simnet -G simnet simnet; \
      else adduser -D -h /home/simnet -G simnet -u $SIMVERSE_HOST_UID simnet; \
    fi

WORKDIR /home/simnet

ENV PATH $PATH:/home/simnet

# we don't want to force entrypoint to not confuse ad-hoc commands via `docker exec`
# see our `run` scripts in individual containers which might decide to use tiny as a wrapper
# ENTRYPOINT ["/sbin/tini", "--"]
# see https://github.com/krallin/tini

# <<< runtime snippet <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<