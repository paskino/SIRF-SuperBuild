#! /bin/bash
# BUILD for Apple and ARM64
set -ex
# default locations
: ${DEVELROOT:=~/Dev/SyneRBI}
: ${BUILDDIR:=${DEVELROOT}/buildVM}
: ${SBDIR:=${DEVELROOT}/SIRF-SuperBuild}
mkdir -p "$BUILDDIR"
cd "$BUILDDIR"
# eval "$(conda shell.bash hook)"
conda env create -n sirfetc -f "$SBDIR"/docker/requirements.yml
conda activate sirfetc
# build CIL ourselves. Not necessary with https://github.com/SyneRBI/SIRF-SuperBuild/pull/946

if command -v nvcc >& /dev/null
then
   conda install -y cuda-driver-dev cuda-cudart-dev cuda-nvcc
fi
conda install -y ninja swig go ccache cmake=3.* armadillo=12.8.4 dcmtk howardhinnant_date eigen libcurl range-v3 libblas=*=*openblas blas-devel=*=*open* gtest gmock plplot pugixml python-wget cython six h5py boost libitk-devel libitk nlohmann_json libparallelproj fftw niftyreg "numpy>=2" pkg-config -c conda-forge
cmake -GNinja -S "$SBDIR" -B "$BUILDDIR" -DUSE_SYSTEM_Armadillo=ON -DUSE_SYSTEM_GTest=ON -DUSE_SYSTEM_range-v3=ON -DUSE_SYSTEM_Date=ON -DGadgetron_USE_MKL=OFF -DCMAKE_INSTALL_PREFIX:PATH="$CONDA_PREFIX" -DCMAKE_PREFIX_PATH:PATH="$CONDA_PREFIX" -DUSE_SYSTEM_ACE=OFF -DUSE_SYSTEM_Boost=ON -DUSE_SYSTEM_ITK=ON -DUSE_SYSTEM_parallelproj=ON -DUSE_SYSTEM_FFTW3=ON -DUSE_SYSTEM_SWIG=ON -DUSE_SYSTEM_HDF5=ON -DUSE_SYSTEM_JSON=ON -DUSE_SYSTEM_NIFTYREG=ON -DUSE_ITK=ON -DBUILD_Gadgetron=ON -DBUILD_CIL=ON -DCCPi-Regularisation-Toolkit_USE_CUDA=OFF -DGadgetron_TAG=avoid_test_compilation_error -DGadgetron_URL=https://github.com/SyneRBI/gadgetron.git -DISMRMRD_TAG=v1.14.3 -DCBLAS_INCLUDE_DIR=$CONDA_PREFIX/include -DCBLAS_LIBRARY=$CONDA_PREFIX/lib/libcblas.dylib 
cmake --build . --config Release
cp "$CONDA_PREFIX"/bin/env_sirf.sh "$CONDA_PREFIX"/etc/conda/activate.d/
conda deactivate
conda activate sirfetc