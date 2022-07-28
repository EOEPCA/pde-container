#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

export PUID="$(id -u)"
export PGID="$(id -g)"

main() {
  if [ "$1" = "down" ]; then
    echo "Shutting down..."
    docker-compose down
  elif [ "$1" = "restart" ]; then
    echo "Restarting..."
    docker-compose down
    build
    docker-compose up -d
  elif [ "$1" = "logs" ]; then
    echo "Logs..."
    docker-compose logs -f
  else
    echo "Running..."
    build
    docker-compose up -d
  fi
}

build() {
  echo "  Building..."
  docker-compose build
  docker system prune -f >/dev/null
}

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

main "$@"
