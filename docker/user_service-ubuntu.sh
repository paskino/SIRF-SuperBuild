#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

source "$INSTALL_DIR"/pyvenv/bin/activate

# SIRF-Exercises
git clone https://github.com/SyneRBI/SIRF-Exercises --recursive -b master $INSTALL_DIR/SIRF-Exercises

if [ -f requirements-service.txt ]; then
  conda install -c conda-forge -y --file requirements-service.txt || \
  pip install -U -r requirements-service.txt
fi

if [ -f requirements-service-jupyterhub.txt ]; then
  conda install -c conda-forge -y --file requirements-service-jupyterhub.txt || \
  pip install -U -r requirements-service-jupyterhub.txt
fi

#install SIRF-Exercises requirements
cd $INSTALL_DIR/SIRF-Exercises
if [ -f requirements.txt ]; then
   # uses only the requirement name not --only-binary and removes empty lines and comments
   awk '{if ($1!="#" && NF) {print $1} }'  requirements.txt > crequirements.txt

   while read in; do 
    conda install -c conda-forge -y ${in} || \
    pip install -U ${in}; done < crequirements.txt

  if [ -f crequirements.txt ] ; then
    rm crequirements.txt
  fi
fi
# configure nbstripout
git config --global filter.nbstripout.extrakeys '
  metadata.celltoolbar metadata.language_info.codemirror_mode.version
  metadata.language_info.pygments_lexer metadata.language_info.version'
  
nbstripout --install
# jupyter labextension install @jupyter-widgets/jupyterlab-manager

# CIL-Demos
git clone https://github.com/TomographicImaging/CIL-Demos.git --recursive -b main $INSTALL_DIR/CIL-Demos
cd $INSTALL_DIR/CIL-Demos
nbstripout --install


