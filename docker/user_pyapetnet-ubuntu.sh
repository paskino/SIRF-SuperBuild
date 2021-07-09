#!/usr/bin/env bash
#!/usr/bin/env bash
[ -f .bashrc ] && . .bashrc
set -ev
INSTALL_DIR="${1:-/opt}"

source "$INSTALL_DIR"/pyvenv/bin/activate
# install pyapetnet requirements
if [ -f requirements-pyapetnet.txt ]; then
  while read in; do 
    echo "Trying to install ${in}"
    conda install -c conda-forge -y ${in} || \
    pip install -U ${in}; done < requirements-pyapetnet.txt
  
fi