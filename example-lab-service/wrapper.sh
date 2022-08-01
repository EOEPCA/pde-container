#!/usr/bin/env bash

main() {
  port=80
  if [ $# -ge 1 ]; then
    p=$(($1+0))
    if [ $p -gt 0 ]; then
      port=$p
      shift
    fi
  fi

  createConfig

  if [ $# -eq 0 ]; then
    exec /docker-entrypoint.sh nginx -g "daemon off;"
  fi
  exec /docker-entrypoint.sh "$@"
}

createConfig() {
  cat - <<EOF >/etc/nginx/conf.d/default.conf
server {
    listen       $port;
    listen  [::]:$port;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
}

main "$@"
