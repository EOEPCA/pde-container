#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

###############Start theia##############################
if [[ ! -L /workspace/package.json  ]]; then
  ln -s /opt/theia/package.json /workspace/package.json
fi

if [[ ! -L /opt/theia/src-gen ]]; then
  ln -s /opt/theia/src-gen /workspace/src-gen
fi

if [[ ! -d /workspace/.theia ]]; then
  mkdir /workspace/.theia
fi

if [[ ! -L /home/jovyan/.theia  ]]; then
  ln -s /workspace/.theia  /home/jovyan/.theia
fi
###############End theia##############################

# Landing page
#static -p 8001 -a 0.0.0.0 /var/www/public/ &
#

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  exec /usr/local/bin/start-singleuser.sh $*
else
  if [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
    . /usr/local/bin/start.sh jupyter lab $*
  else
    . /usr/local/bin/start.sh jupyter notebook $*
  fi
fi