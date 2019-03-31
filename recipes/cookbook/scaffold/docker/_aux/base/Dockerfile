FROM golang:1.11-alpine

RUN apk add --no-cache \
    bash fish \
    ca-certificates \
    curl git

RUN go get -u github.com/go-delve/delve/cmd/dlv
RUN dlv version