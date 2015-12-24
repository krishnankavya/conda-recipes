#!/bin/bash

conda env remove -y -n cantera-builder
conda create -y -n cantera-builder python=2 numpy scons cython
CANTER_MINOR_VER=${PKG_VERSION:2:1}
PY_MAJ_VER=${PY_VER:0:1}

if [ "${PY_MAR_VER}" == "2" ]; then
    pip install 3to2
fi

OLD_PATH=$PATH
export PATH=${PREFIX%_build}cantera-builder/bin:$PATH

scons clean

if [ "${CANTERA_MINOR_VER}" -gt "2" ]; then
    echo "system_sundials='n'" >> cantera.conf
fi

if [ "${PY_MAJ_VER}" == "2" ]; then
    scons build -j$((CPU_COUNT/2)) python3_package='n' python_cmd=$PYTHON python_package='full' matlab_toolbox='n' f90_interface='n'
else
    scons build -j$((CPU_COUNT/2)) python3_package='y' python3_cmd=$PYTHON python_package='none' matlab_toolbox='n' f90_interface='n'
fi

conda env remove -y -n cantera-builder

export PATH=$OLD_PATH

if [ "${PY_MAJ_VER}" == "2" ]; then
    pip uninstall -y 3to2
fi

cd interfaces/cython
$PYTHON setup${PY_MAJ_VER}.py build --build-lib=../../build/python${PY_MAJ_VER} install
