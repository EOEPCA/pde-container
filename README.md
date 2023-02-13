# pde-container

[![Project Status: Suspended – Initial development has started, but there has not yet been a stable, usable release; work has been stopped for the time being but the author(s) intend on resuming work.](https://www.repostatus.org/badges/latest/suspended.svg)](https://www.repostatus.org/#suspended)


_PDE Notebooks base image featuring JupyterLab and the Theia IDE._

- [pde-container](#pde-container)
  - [Running with Docker](#running-with-docker)
  - [Additional Services](#additional-services)
  - [Additional Services as Containers](#additional-services-as-containers)
  - [Spawning from JupyterHub](#spawning-from-jupyterhub)
    - [DockerSpawner](#dockerspawner)
      - [Example](#example)
    - [KubeSpawner](#kubespawner)
      - [Example](#example-1)

The PDE container is designed to be spawned from [JupyterHub](https://jupyter.org/hub) in a multi-user deployment, but can also be invoked directly with docker.

## Running with Docker

The PDE container can be run directly using docker - which allows to run the PDE as a local tool, whilst also being useful for PDE development.

```bash
docker run --rm --name pde --privileged -p 8888:8888 eoepca/pde-container
```

The `--privileged` flag enables the use of `podman` within the PDE container - for example, to integrate additional containerised services within the PDE offering.

## Additional Services

The JupyterLab interface of the PDE container - available at the URL `http://127.0.0.1:8888/lab` - supports the integration of additional web services. Such services are configured in the Jupyter configuration file (/etc/jupyter/jupyter_notebook_config.py). The following example inetgrates the Theia IDE...

```python
#--snip--
c.ServerProxy.servers = {
  'theia': {
    'command': [
      '/home/jovyan/.nvm/versions/node/v12.22.7/bin/yarn',
        'start', 
        '/workspace',
        '--hostname=0.0.0.0',
        '--port={port}'
    ],
    'timeout': 30,
    'launcher_entry': {
      'title': 'Theia'
    }
  },
}
#--snip--
```

Note that the server must run as a web service that is configured at runtime with the provided listening `{port}`. Access to the service is proxied via JupyterLab to this target `{port}`.

## Additional Services as Containers

The additional service example above relies upon the web service binaries being included within the PDE container - as is the case for the Theia IDE above.

Alternatively, services can be configured to be invoked as containers via `podman` which is built-in to the PDE container. For example, a dummy service that runs a simple nginx web server...

```python
#--snip--
  'example-service': {
    'command': [
      'podman',
      'run',
      'docker.io/eoepca/example-pde-service',
      '{port}',
    ],
    'timeout': 45,
    'launcher_entry': {
      'title': 'Example Service'
    }
  },
#--snip--
```

The container image `eoepca/example-pde-service` is created from the `example-lab-service/Dockerfile` - which simply wraps the `nginx` container with the ability to receive the listening port as a command-line argument.

The following command can be used to run the PDE container with this example service integrated...

```bash
docker run --rm --name pde --privileged -p 8888:8888 -v $PWD/example-lab-service/jupyter_notebook_config.py:/etc/jupyter/jupyter_notebook_config.py eoepca/pde-container
```

Navigate to the JupyterLab page http://127.0.0.1:8888/lab and select the `Example Service` entry to invoke the Nginx service. There may be a delay whilst the `example-pde-service` container image is pulled before being invoked.

## Spawning from JupyterHub

JupyterHub can be run from the [docker.io/jupyterhub/jupyterhub](https://hub.docker.com/r/jupyterhub/jupyterhub) container image, which is configured via the file `/srv/jupyterhub/jupyterhub_config.py`.

JupyterHub spawns a service instance for each user that logs in to the hub. Instances can be spawned as containers using the `DockerSpawner` or `KubeSpawner`.

The spawner is configured via the `jupyterhub_config.py` file...

### DockerSpawner

See [https://github.com/jupyterhub/dockerspawner](https://github.com/jupyterhub/dockerspawner).

Snip from file `/srv/jupyterhub/jupyterhub_config.py`...
```python
# launch with docker
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"

# pick a docker image. This should have the same version of jupyterhub in it as our Hub.
# c.DockerSpawner.image = 'jupyterhub/singleuser:2.3.1'
c.DockerSpawner.image = 'eoepca/pde-container'

# delete containers when the stop
c.DockerSpawner.remove = True
```

#### Example

See sub-directory `jupyterhub-docker` for an example of running JupyterHub from the [docker.io/jupyterhub/jupyterhub](https://hub.docker.com/r/jupyterhub/jupyterhub) container image with the DockerSpawner configured to invoke the [docker.io/jupyterhub/singleuser](https://hub.docker.com/r/jupyterhub/singleuser) container image.

The example can be instantiated by running...
```
./jupyterhub-docker/jupyterhub-docker.sh
```

This approach can be used for local testing of the PDE container being spawned from JupyterHub.

### KubeSpawner

See [https://github.com/jupyterhub/kubespawner](https://github.com/jupyterhub/kubespawner).

Snip from file `/srv/jupyterhub/jupyterhub_config.py`...
```python
# launch with Kubernetes
c.JupyterHub.spawner_class = "kubespawner.KubeSpawner"

# image to spawn
c.KubeSpawner.image = "eoepca/pde-container"
```

#### Example

There are many configuration options for `KubeSpawner`. See the [helm chart](https://github.com/EOEPCA/helm-charts/tree/main/charts/pde-jupyterhub) for deployment of the full [JupyterHub PDE](https://github.com/EOEPCA/helm-charts/tree/main/charts/pde-jupyterhub) to Kubernetes.
