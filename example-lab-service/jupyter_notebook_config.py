# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

from jupyter_core.paths import jupyter_data_dir
import subprocess
import os
import errno
import stat
import logging

c = get_config()

c.FileContentsManager.delete_to_trash=False

c.NotebookApp.ip = '*'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False

# redirect to /lab
#c.Spawner.default_url = '/landing'

# Generate a self-signed certificate
if 'GEN_CERT' in os.environ:
    dir_name = jupyter_data_dir()
    pem_file = os.path.join(dir_name, 'notebook.pem')
    try:
        os.makedirs(dir_name)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(dir_name):
            pass
        else:
            raise
    # Generate a certificate if one doesn't exist on disk
    subprocess.check_call(['openssl', 'req', '-new',
                           '-newkey', 'rsa:2048',
                           '-days', '365',
                           '-nodes', '-x509',
                           '-subj', '/C=XX/ST=XX/L=XX/O=generated/CN=generated',
                           '-keyout', pem_file,
                           '-out', pem_file])
    # Restrict access to the file
    os.chmod(pem_file, stat.S_IRUSR | stat.S_IWUSR)
    c.NotebookApp.certfile = pem_file
    

c.FileContentsManager.delete_to_trash=False

# c.NotebookApp.ip = '*'
# c.NotebookApp.port = 8888
# c.NotebookApp.open_browser = False

# c.NotebookApp.notebook_dir = '/workspace'

# Theia IDE
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
  'landing': {
    'command': [
      '/usr/bin/serve-docs',
      '{port}',
    ],
    'timeout': 45,
    'launcher_entry': {
      'title': 'Docs'
    }
  },
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
  }
}
