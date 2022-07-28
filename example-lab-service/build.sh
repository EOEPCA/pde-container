#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

main() {
  docker build -t eoepca/example-pde-service .
  docker push eoepca/example-pde-service
}

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

main "$@"
