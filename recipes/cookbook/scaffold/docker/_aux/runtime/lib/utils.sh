#!/usr/bin/env bash

echo_err() {
  printf "\e[31m%s\e[0m\n" "$*" >&2;
}

wait_for_socket() {
  local port=${1:?required}
  local host=${2:-localhost}
  local max=${3:-100}
  local delay=${4:-1}

  local counter=1
  while ! nc -z "$host" "$port" > /dev/null 2>&1; do
    sleep ${delay}
    ((++counter))
    if [[ ${counter} -gt ${max} ]]; then
      echo_err "socket '$host:$port' didn't come online in time"
      return 1
    fi
  done
}

generate_cert() {
  local name=${1:-ssl}
  local cert_file="$name.cert"
  local key_file="$name.key"
  local csr_file="$name.csr"
  local cnf_file=openssl.cnf

  cat /etc/ssl/openssl.cnf > "$cnf_file"
  cat >> "$cnf_file" <<EOF

[ SAN ]
subjectAltName=DNS:*

EOF

  openssl ecparam \
    -genkey \
    -name secp521r1 \
    -out "$key_file"
  openssl req \
    -new \
    -out "$csr_file" \
    -sha512 -key "$key_file" \
    -subj '/CN=localhost/O=simverse' \
    -extensions SAN \
    -config "$cnf_file"
  openssl req \
    -x509 \
    -out "$cert_file" \
    -sha512 \
    -days 36500 \
    -key "$key_file" \
    -in "$csr_file" \
    -extensions SAN \
    -config "$cnf_file"

  rm "$csr_file"
  rm "$cnf_file"
}

signal_service_ready() {
  local answer=${1:-READY}
  SERVICE_READY_PORT=${SERVICE_READY_PORT}
  local port=${SERVICE_READY_PORT:?required}
  exec nc -nlk -p "$port" -e sh -c "echo -e \"$answer\""
}