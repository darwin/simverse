FROM golang:1.11-alpine

ARG SIMVERSE_HOST_UID
ARG SIMVERSE_HOST_GID

RUN apk add --no-cache \
    bash fish \
    ca-certificates \
    curl git

RUN go get -u github.com/go-delve/delve/cmd/dlv
RUN dlv version

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