#! /bin/bash

mkdir build
cd build

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Target deployment at the El Capitan SDK
    export MACOSX_DEPLOYMENT_TARGET=10.11

    cmake $SRC_DIR -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DEXAMPLES_ENABLE=OFF \
    -DEXAMPLES_INSTALL=OFF -DCMAKE_MACOSX_RPATH=ON

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    cmake $SRC_DIR -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DEXAMPLES_ENABLE=OFF \
    -DEXAMPLES_INSTALL=OFF
fi

make -j$((CPU_COUNT/2))
make install
