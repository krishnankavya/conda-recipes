#!/bin/bash

conda env remove -y -n cantera-builder
conda create -y -n cantera-builder python=2 numpy scons cython
OLD_PATH=$PATH
export PATH=${PREFIX%_build}cantera-builder/bin:$PATH

scons clean

if [ "${PY_VER:0:1}" == "2" ]; then
    scons build -j$((CPU_COUNT/2)) python3_package='n' python_package='full' matlab_toolbox='n' f90_interface='n' system_sundials='n'
else
    scons build -j$((CPU_COUNT/2)) python3_package='y' python3_cmd=${PREFIX}/bin/python python_package='none' matlab_toolbox='n' f90_interface='n' system_sundials='n'
fi

conda env remove -y -n cantera-builder

export PATH=$OLD_PATH
cd interfaces/cython
$PYTHON setup${PY_VER:0:1}.py build --build-lib=../../build/python${PY_VER:0:1} install
