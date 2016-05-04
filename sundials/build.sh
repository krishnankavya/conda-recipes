#! /bin/bash

mkdir build
cd build

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Target deployment at the El Capitan SDK
    export MACOSX_DEPLOYMENT_TARGET=10.11

    cmake $SRC_DIR -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_FLAGS="-L$PREFIX/lib" \
    -DEXAMPLES_ENABLE=OFF -DEXAMPLES_INSTALL=OFF -DLAPACK_ENABLE=ON -DPTHREAD_ENABLE=ON \
    -DLAPACK_LIBRARIES="mkl_intel_lp64;mkl_core;mkl_intel_thread;pthread;iomp5;m;dl" -DCMAKE_MACOSX_RPATH=ON

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    cmake $SRC_DIR -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_FLAGS="-L$PREFIX/lib" \
    -DEXAMPLES_ENABLE=OFF -DEXAMPLES_INSTALL=OFF -DLAPACK_ENABLE=ON -DPTHREAD_ENABLE=ON -DOPENMP_ENABLE=ON \
    -DLAPACK_LIBRARIES="mkl_intel_lp64;mkl_core;mkl_intel_thread;pthread;iomp5;m;dl"
fi

make -j$((CPU_COUNT/2))
make install
