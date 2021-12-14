FROM quay.io/podman/stable:latest

USER root

ADD install-yum.bash /tmp/install-yum.bash
ADD yum.list /tmp/yum.list
RUN set -x && chmod 755 /tmp/install-yum.bash && \
	/tmp/install-yum.bash && \
	yum install -y findutils libsecret

ENV NB_USER=jovyan \
    NB_UID=1001 \
    NB_GID=100 \
    SHELL=bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    CONDA_DIR=/opt/anaconda \
    NB_PYTHON_PREFIX=/opt/anaconda/envs/notebook

ENV USER=${NB_USER} \
    NB_UID=${NB_UID} \
    HOME=/home/${NB_USER} \
    PATH=/opt/theia/node_modules/.bin/:$NB_PYTHON_PREFIX/bin:$CONDA_DIR/bin:$PATH

ADD fix-permissions /usr/local/bin/fix-permissions

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME

# conda installation via miniforge
ADD install-miniforge.bash /tmp/install-miniforge.bash

ADD environment.yml /tmp/environment.yml

RUN chmod 755 /tmp/install-miniforge.bash && \
    /tmp/install-miniforge.bash

# extensions
ADD install-extensions.bash /tmp/install-extensions.bash

RUN chmod 755 /tmp/install-extensions.bash && \
    /tmp/install-extensions.bash

# data
RUN mkdir -p /workspace/data && \
    chown -R ${NB_USER}:${NB_GID} /workspace && \
    chown -R ${NB_USER}:${NB_GID} /workspace

# clean-up
RUN rm -f /tmp/install-*.bash && \
    rm -f /tmp/environment.yml

# for additional kernels
RUN mkdir -p /usr/local/share/jupyter && \
    chown -R $NB_USER:$NB_GID /usr/local/share/jupyter

# fix permissions
RUN chown -R $NB_USER:$NB_GID ${HOME} && \
    mkdir /opt/theia && \
    chown -R $NB_USER:$NB_GID /opt/theia


USER ${NB_USER}

# setup conda activate/deactivate
RUN ${CONDA_DIR}/bin/conda init bash && \
    source ${HOME}/.bashrc

# workdir for binder
WORKDIR ${HOME}

RUN curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash             && \
    source ${HOME}/.bashrc && nvm install 12 && npm install -g yarn                                 && \
    source ${HOME}/.bashrc

ADD package.json /opt/theia/package.json

USER ${NB_USER}
RUN source /home/jovyan/.bashrc && \
    cd /opt/theia && THEIA_ELECTRON_SKIP_REPLACE_FFMPEG=1 yarn && \
    source /home/jovyan/.bashrc && \
    cd /opt/theia && \
    yarn theia build && \
    source /home/jovyan/.bashrc && \
    yarn cache clean

# from l2-binder
USER root




ENTRYPOINT ["tini", "--"]



USER ${NB_USER}

RUN $CONDA_DIR/bin/conda config --add envs_dirs /workspace/.conda/envs  && \
    mkdir -p /workspace/.conda/envs                               	&& \
    $CONDA_DIR/bin/conda config --add pkgs_dirs /workspace/.conda/pkgs && \
    mkdir -p /workspace/.conda/pkgs

USER root
RUN ln -s /usr/bin/podman /usr/bin/docker # required by cwltool docker pull even if running with --podman

# kubectl
RUN curl -s -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  && \
    chmod +x kubectl                                                                                                    && \
    mv ./kubectl /usr/bin/kubectl

# yq, jq, aws cli
RUN VERSION="v4.12.2"                                                                               && \
    BINARY="yq_linux_amd64"                                                                         && \
    wget --quiet https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
    tar xz && mv ${BINARY} /usr/bin/yq                                                              && \
    curl -s -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > /usr/bin/jq     && \
    chmod +x /usr/bin/jq                                                                            && \
    /opt/anaconda/bin/pip3 install awscli                                                           && \
    /opt/anaconda/bin/pip3 install awscli-plugin-endpoint

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini && \
    chmod +x /usr/local/bin/start.sh && \
    chmod +x /usr/local/bin/start-notebook.sh && \
    chmod +x /usr/local/bin/start-singleuser.sh

# web site
ENV NVM_DIR=$HOME/.nvm
RUN . "$NVM_DIR/nvm.sh"                                                                             && \
    npm install -g node-static                                                                      && \
    /opt/anaconda/bin/pip install mkdocs-material                                                   && \
    mkdir -p /var/www                                                                               && \
    chown -R ${NB_USER}:${NB_GID} /var/www

COPY --chown=1001:100 docs /var/www/

RUN cd /var/www/                                                                                    && \
    mkdocs build                                                                                    && \
    rm -fr src && rm mkdocs.yml  

ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

ADD serve-docs /usr/bin/serve-docs 

RUN chmod +x  /usr/bin/serve-docs 


USER ${NB_USER}

WORKDIR /workspace
CMD ["start-notebook.sh"]
