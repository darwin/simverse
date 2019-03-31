FROM golang:1.11-alpine

ARG GCFLAGS
ENV GCFLAGS=$GCFLAGS

# install build dependencies
RUN apk add --no-cache --update git gcc musl-dev alpine-sdk make
