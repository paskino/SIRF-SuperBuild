#! /bin/bash

pip install --upgrade pip

pip install torch==1.7.1
pip install scikit-learn


# Installs the wheel compatible with CUDA 11 and cuDNN 8.2 or newer.
pip install --upgrade "jax[cuda]" -f https://storage.googleapis.com/jax-releases/jax_releases.html  # Note: wheels only available on linux.

 
#pyvista 
#Requires libgl1-mesa-dev and xvfb installed through apt-get and the configuration of an headless display at startup of the container. 
apt-get install -yq libgl1-mesa-dev xvfb
conda install -c conda-forge pyvista -y
#See details here: https://docs.pyvista.org/getting-started/installation.html#running-on-mybinder

# Morphomatics
pip install git+https://github.com/morphomatics/morphomatics.git#egg=morphomatics
 
pip install ipyvtklink
pip install ipygany