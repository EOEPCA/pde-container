ARG JUPYTERHUB_VERSION=2.3.1
FROM jupyterhub/jupyterhub:$JUPYTERHUB_VERSION

COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache -r /tmp/requirements.txt
