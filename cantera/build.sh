#!/bin/bash

conda env remove -y -n cantera-builder
conda create -y -n cantera-builder python=2 numpy scons cython
PY_MAJ_VER=${PY_VER:0:1}

if [ "${PY_MAJ_VER}" == "2" ]; then
    pip install 3to2
fi

OLD_PATH=$PATH
export PATH=${PREFIX%_build}cantera-builder/bin:$PATH

scons clean

# We want neither the MATLAB interface nor the Fortran interface
echo "matlab_toolbox='n'" >> cantera.conf
echo "f90_interface='n'" >> cantera.conf

if [ "${PY_MAJ_VER}" == "2" ]; then
    scons build -j$((CPU_COUNT/2)) python3_package='n' python_cmd=$PYTHON python_package='full'
else
    scons build -j$((CPU_COUNT/2)) python3_package='y' python3_cmd=$PYTHON python_package='none'
fi

conda env remove -y -n cantera-builder

export PATH=$OLD_PATH

cd interfaces/cython
$PYTHON setup${PY_MAJ_VER}.py build --build-lib=../../build/python${PY_MAJ_VER} install
