
# >>> buildtime snippet >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# this is a Dockerfile snippet used in docker containers for building

ARG GCFLAGS
ENV GCFLAGS=$GCFLAGS

# install build dependencies
RUN apk add --no-cache --update \
musl-dev \
alpine-sdk \
gcc \
make \
file \
autoconf \
automake \
build-base \
libtool \
db-c++ \
db-dev \
boost-system \
boost-program_options \
boost-filesystem \
boost-dev \
libressl-dev \
libevent-dev \
zeromq-dev

# <<< buildtime snippet <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<