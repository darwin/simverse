#!/usr/bin/env bash

DOCKER_COMPOSE_VERSION=1.23.2

install_linux() {
  # https://docs.docker.com/compose/install/#prerequisites
  sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version
}

install_mac() {
  brew install docker-compose
}

case "$OSTYPE" in
  linux*) install_linux ;;
  darwin*) install_mac ;;
  *) echo "unsupported: $OSTYPE" ;;
esac