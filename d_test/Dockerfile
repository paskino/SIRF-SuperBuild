ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE} as base

LABEL \
  author.name="Casper da Costa-Luis, Kris Thielemans, Edoardo Pasca"                 \
  author.email=imaging@caspersci.uk.to        \
  maintainer.email=ccppetmr@stfc.ac.uk        \
  maintainer.url=https://www.ccpsynerbi.ac.uk/  \
  source.url=https://github.com/SyneRBI/SIRF-SuperBuild/  \
  licence="MPLv2.0 (https://www.mozilla.org/en-GB/MPL/2.0/)"  \
  description="CCP SyneRBI Ubuntu"

USER root
ENV DEBIAN_FRONTEND noninteractive

# this triggers a cache miss
# https://github.com/MShekow/directory-checksum/

RUN apt-get update -qq && apt-get install -yq --no-install-recommends curl && apt-get clean

ADD https://github.com/MShekow/directory-checksum/releases/download/v1.4/directory-checksum_1.4_linux_amd64 /usr/local/bin/directory-checksum
RUN  chmod +x /usr/local/bin/directory-checksum

# copy all install scripts to the image
# COPY ./ /opt/SIRF-SuperBuild/
COPY ./docker/*.sh ./install_scripts/

RUN cd ./install_scripts/ &&\
    bash update_nvidia_keys.sh\
    bash raw-ubuntu.sh

# Set locale, suppress warnings
#ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en

FROM base as core

RUN cd ./install_scripts/ &&\
    bash build_essential-ubuntu.sh &&\
    bash build_python-ubuntu.sh &&\
    bash build_gadgetron-ubuntu.sh &&\
    bash build_system-ubuntu.sh &&\
    apt-get update -qq && apt-get install -yq --no-install-recommends \
      libx11-xcb1 gosu &&\
    apt-get clean &&\
    mkdir -p /usr/share/X11/xkb &&\
    [ -e /usr/bin/X ] || ln -s /usr/bin/Xorg /usr/bin/X &&\
    cp entrypoint.sh /usr/local/bin/
    
ENV DEBIAN_FRONTEND ''
WORKDIR /home-away
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]


FROM core as sirf
LABEL description="CCP SyneRBI SIRF"

# create user jovyan (jupyterhub seems to require this name)
ARG NB_USER="jovyan"
ARG NB_GROUP="users"
# some crazy number, hopefully not conflicting
ARG NB_UID="22222"
# standard guid for users
ARG NB_GID="100"
ARG HOME="/home/${NB_USER}"
ARG PYTHON_INSTALL_DIR="/opt/conda"
ARG PYTHON_EXECUTABLE="miniconda"

ENV DEBIAN_FRONTEND noninteractive

# copy all SuperBuild files to the image
COPY ./ /opt/SIRF-SuperBuild/
RUN directory-checksum --max-depth 2 /opt/SIRF-SuperBuild


# make /opt  writeable for all users
RUN chmod go+rwx /opt &&\
    cp /opt/SIRF-SuperBuild/docker/.bashrc . &&\
    cp /opt/SIRF-SuperBuild/docker/.profile . &&\
    (addgroup --gid ${NB_GID} "${NB_GROUP}" || true) && \
    (useradd -l -m -s /bin/bash -N -u "${NB_UID}" -g "${NB_GID}" "${NB_USER}" || true) &&\
    chmod 644 .bashrc .profile && chown -R "${NB_USER}":"${NB_GROUP}" "${HOME}" &&\
    chown -R "${NB_USER}":"${NB_GROUP}" /opt/SIRF-SuperBuild &&\
    sed -i s:PYTHON_INSTALL_DIR:${PYTHON_INSTALL_DIR}:g .bashrc


# run user scripts as NB_USER
USER ${NB_USER}:${NB_GROUP}

# Python (virtualenv or conda)
# COPY requirements.txt .
# COPY requirements.yml .
# COPY user_python-ubuntu.sh .
RUN cp /opt/SIRF-SuperBuild/docker/user_python-ubuntu.sh ${HOME} &&\
    cd ${HOME} &&\
    PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} PYTHON_INSTALL_DIR=${PYTHON_INSTALL_DIR} bash user_python-ubuntu.sh
    

# ccache
USER root
COPY docker/devel/.ccache/ /opt/ccache/
# give everyone write permisions
RUN chmod -R go+w /opt/ccache


# SIRF
USER "${NB_USER}"

# SIRF-SuperBuild version
ARG SIRF_SB_URL="https://github.com/SyneRBI/SIRF-SuperBuild"
ARG SIRF_SB_TAG="master"

# set if we want to remove the build files
ARG REMOVE_BUILD_FILES=1
# set if we want to run the tests during build
ARG RUN_CTEST=1

# speeding up the cmake build
# (implementation note: changing this in your environment will invalidate the docker cache sadly)
ARG NUM_PARALLEL_BUILDS="2"

ARG BUILD_FLAGS="\
 -DCMAKE_BUILD_TYPE=Release\
 -DSTIR_ENABLE_OPENMP=ON -DUSE_SYSTEM_ACE=ON\
 -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_Boost=ON\
 -DUSE_SYSTEM_FFTW3=ON -DUSE_SYSTEM_HDF5=OFF -DUSE_ITK=ON\
 -DGadgetron_USE_CUDA=OFF\
 -DUSE_SYSTEM_SWIG=ON\
 -DUSE_NiftyPET=OFF\
 -DBUILD_siemens_to_ismrmrd=ON -DBUILD_pet_rd_tools=ON"
ARG EXTRA_BUILD_FLAGS="-DBUILD_CIL=OFF"

# build it, run ctest if required, and give everyone write and execute permission

RUN ccache -o cache_dir=/opt/ccache &&\
    cd /opt/SIRF-SuperBuild/docker &&\
    bash user_sirf-ubuntu.sh \
    && chmod -R go+rwX /opt/SIRF-SuperBuild/INSTALL

ENV DEBIAN_FRONTEND ''

# go back to root (entrypoint.sh will switch users)
USER root
CMD ["/bin/bash"]


# FROM sirf as service

# ENV DEBIAN_FRONTEND noninteractive

# ARG NB_USER="jovyan"
# ARG NB_GROUP="users"
# ARG HOME="/home/${NB_USER}"

# USER "${NB_USER}"

# # COPY requirements-service.txt .
# # COPY requirements-service.yml .
# # COPY requirements.yml .
# # COPY user_service-ubuntu.sh .
# # COPY install-sirf-exercises-dep.py .
# RUN cd /opt/SIRF-SuperBuild/docker &&\
#     PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} PYTHON_INSTALL_DIR=${PYTHON_INSTALL_DIR} bash user_service-ubuntu.sh


# USER root
# RUN cp /opt/SIRF-SuperBuild/docker/download_data.sh /usr/local/bin/ &&\
#     cp /opt/SIRF-SuperBuild/docker/service.sh /usr/local/bin/
# ENV DEBIAN_FRONTEND ''
# CMD ["/usr/local/bin/service.sh"]

# # note: remain root (entrypoint.sh will switch users)

# FROM service as multi
# COPY service.multi.sh /usr/local/bin/

# FROM sirf as jupyterhub

# ENV DEBIAN_FRONTEND noninteractive

# ARG NB_USER="jovyan"
# ARG NB_GROUP="users"
# ARG HOME="/home/${NB_USER}"

# USER root

# # Install all OS dependencies for notebook server that starts but lacks all
# # features (e.g., download as all possible file formats)
# ENV DEBIAN_FRONTEND noninteractive
# RUN apt-get update --yes && \
#     apt-get install --yes --no-install-recommends \
#     wget \
#     ca-certificates \
#     sudo \
#     tini \
#     locales \
#     fonts-liberation \
#     run-one && \
#     apt-get clean && rm -rf /var/lib/apt/lists/* &&\
#     echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#     sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#     sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers

# USER "${NB_USER}"

# ENTRYPOINT ["/tini", "-g", "--"]
# # TODO some stuff here
# #CMD ["/usr/local/bin/service-jupyterhub.sh"]

# # TODO set some env variables (or do it in a compose file)

# ENV DEBIAN_FRONTEND ''
