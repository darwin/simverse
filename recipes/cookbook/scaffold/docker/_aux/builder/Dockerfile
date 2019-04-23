FROM golang:1.12-alpine

ARG GCFLAGS
ENV GCFLAGS=$GCFLAGS

# install build dependencies
RUN apk add --no-cache --update \
musl-dev \
alpine-sdk \
git \
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