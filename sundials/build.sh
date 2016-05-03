#! /bin/bash

mkdir build
cd build

cmake $SRC_DIR -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_FLAGS="-L$LD_RUN_PATH" \
-DEXAMPLES_ENABLE=OFF -DEXAMPLES_INSTALL=OFF -DLAPACK_ENABLE=ON  -DPTHREAD_ENABLE=ON -DOPENMP_ENABLE=ON \
-DLAPACK_LIBRARIES="mkl_intel_lp64;mkl_core;mkl_intel_thread;pthread;iomp5;m;dl"

make -j$((CPU_COUNT/2))
make install
