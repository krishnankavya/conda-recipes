@ECHO off

:: Remove the old builder environment, if it exists
CALL conda env remove -yq -n cantera-builder

:: Create a conda environment to build Cantera. It has to be Python 2, for
:: Scons compatibility. When SCons is available for Python 3, these machinations
:: can be removed
:: Important: As of 24-Dec-2015, the most recent version of SCons available in
:: the conda repositories is 2.3.0. Unfortunately, using VS 2015 requires SCons
:: 2.4.1. This version is available from my channel on anaconda.org, so we add
:: -c bryanwweber to pick up SCons from that channel.
CALL conda create -yq -n cantera-builder -c cantera/label/builddeps python=2 cython numpy pywin32 scons

:: The major version of the Python that will be used for the installer, not the
:: version used for building
SET PY_MAJ_VER=%PY_VER:~0,1%

:: Set the number of CPUs to use in building
SET /A CPU_USE=%CPU_COUNT% / 2

:: Set up to use the cantera-builder environment
CALL activate.bat cantera-builder

:: Have to use CALL to prevent the script from exiting after calling SCons
CALL scons clean

:: Put important settings into cantera.conf for the build. Use VS 2015 to
:: compile the interface.
ECHO msvc_version='14.0' >> cantera.conf
ECHO env_vars='all' >> cantera.conf
ECHO matlab_toolbox='n' >> cantera.conf
ECHO debug='n' >> cantera.conf
ECHO f90_interface='n' >> cantera.conf
ECHO system_sundials='n' >> cantera.conf

:: Select which version of the interface should be built
IF %PY_MAJ_VER% EQU 2 GOTO PYTHON2
IF %PY_MAJ_VER% EQU 3 GOTO PYTHON3

:PYTHON2
ECHO Building for Python 2
CALL conda install -c cantera/label/builddeps 3to2
CALL scons build -j%CPU_COUNT% python3_package=n python_cmd="%PYTHON%" python_package=full
GOTO BUILD_SUCCESS

:PYTHON3
ECHO Building for Python 3
CALL scons build -j%CPU_COUNT% python3_package=y python3_cmd="%PYTHON%" python_package=none
GOTO BUILD_SUCCESS

:BUILD_SUCCESS
:: Reset the environment and remove the builder environment
CALL deactivate.bat
CALL conda env remove -yq -n cantera-builder

:: Change to the Python interface directory and run the installer using the
:: proper version of Python.
cd interfaces/cython
"%PYTHON%" setup%PY_MAJ_VER%.py build --build-lib=../../build/python%PY_MAJ_VER% install
