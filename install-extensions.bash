#!/bin/bash

set -ex

# make sure we don't do anything funky with user's $HOME
# since this is run as root
unset HOME

# required extensions
${NB_PYTHON_PREFIX}/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension

# ipyleaflet
${NB_PYTHON_PREFIX}/bin/jupyter labextension install jupyter-leaflet
${NB_PYTHON_PREFIX}/bin/jupyter nbextension enable --py --sys-prefix ipyleaflet

# voila
${NB_PYTHON_PREFIX}/bin/jupyter nbextension install voila --sys-prefix --py
${NB_PYTHON_PREFIX}/bin/jupyter nbextension enable voila --sys-prefix --py

# voila preview on jupyter lab (voila is used via notebook, not via lab)
### ${NB_PYTHON_PREFIX}/bin/jupyter labextension install @jupyter-voila/jupyterlab-preview

# geojson
${NB_PYTHON_PREFIX}/bin/jupyter labextension install @jupyterlab/geojson-extension

# sidecar
${NB_PYTHON_PREFIX}/bin/pip install sidecar
${NB_PYTHON_PREFIX}/bin/jupyter labextension install @jupyter-widgets/jupyterlab-sidecar

# templates
#${NB_PYTHON_PREFIX}/bin/pip install jupyterlab_templates
#${NB_PYTHON_PREFIX}/bin/jupyter labextension install jupyterlab_templates
#${NB_PYTHON_PREFIX}/bin/jupyter serverextension enable jupyterlab_templates --py 

# bash kernel
${NB_PYTHON_PREFIX}/bin/pip install bash_kernel
${NB_PYTHON_PREFIX}/bin/python -m bash_kernel.install

# table of contents
${NB_PYTHON_PREFIX}/bin/jupyter labextension install @jupyterlab/toc

# collapsible headings
${NB_PYTHON_PREFIX}/bin/jupyter labextension install @aquirdturtle/collapsible_headings

# server proxy
${NB_PYTHON_PREFIX}/bin/pip install jupyter-server-proxy
#${NB_PYTHON_PREFIX}/bin/jupyter serverextension enable --sys-prefix jupyter_server_proxy
${NB_PYTHON_PREFIX}/bin/jupyter labextension install @jupyterlab/server-proxy

# Remove the pip cache created as part of installing sidecar
rm -rf /root/.cache
rm -fr /tmp/npm*
rm -fr /tmp/yarn*
rm -fr /tmp/v8-compile-cache-*