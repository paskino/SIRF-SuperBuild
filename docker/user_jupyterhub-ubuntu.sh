#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

if [ -f requirements-service-jupyterhub.txt ]; then
  conda install -c conda-forge -y --file requirements-service-jupyterhub.txt || \
  pip install -U -r requirements-service-jupyterhub.txt
fi
# jupyter labextension install @jupyter-widgets/jupyterlab-manager
