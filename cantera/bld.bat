@ECHO off
conda env remove -y -n cantera-build
conda create -y -n cantera-build python=2.7 cython numpy pywin32
conda install -y --use-local -n cantera-build scons

SET PY_MAJ_VER=%PY_VER:~0,1%
SET /A CPU_USE=%CPU_COUNT% / 2

IF %PY_MAJ_VER% EQU 2 pip install 3to2

SET OLD_PATH=%PATH%
SET PATH=%PREFIX:~0,-6%cantera-build\bin;%PREFIX:~0,-6%cantera-build\Scripts;%PATH%

CALL scons clean

ECHO msvc_version='14.0' >> cantera.conf
ECHO env_vars='all' >> cantera.conf
ECHO matlab_toolbox='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf

IF %PY_MAJ_VER% EQU 2 GOTO PYTHON2
IF %PY_MAJ_VER% EQU 3 GOTO PYTHON3

:PYTHON2
ECHO Building for Python 2
CALL scons build -j%CPU_COUNT% python3_package=n python_cmd="%PYTHON%" python_package=full
GOTO BUILD_SUCCESS

:PYTHON3
ECHO Building for Python 3
CALL scons build -j%CPU_COUNT% python3_package=y python3_cmd="%PYTHON%" python_package=none
GOTO BUILD_SUCCESS

:BUILD_SUCCESS
conda env remove -y -n cantera-build
SET PATH=%OLD_PATH%

cd interfaces/cython
"%PYTHON%" setup%PY_MAJ_VER%.py build --build-lib=../../build/python%PY_MAJ_VER% install
