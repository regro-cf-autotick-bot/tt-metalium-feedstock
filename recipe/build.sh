#!/bin/env/bash
set -e

# Needed so that sfpi can be invoked at build time to generate object files
# sfpi links libmpc.so at runtime
export LD_LIBRARY_PATH=$PREFIX/lib

# Avoid overloading build machine processors and memory
export NUM_PROCS=$((CPU_COUNT / 2))

# Needed by python setup.py
export TT_FROM_PRECOMPILED_DIR=$SRC_DIR

cmake \
  $CMAKE_ARGS \
  -G Ninja \
  -S $SRC_DIR \
  -B $SRC_DIR/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_DISTRIBUTED=OFF \
  -DCMAKE_SKIP_INSTALL_RPATH=ON

cmake --build $SRC_DIR/build --parallel $NUM_PROCS

cmake --install $SRC_DIR/build

# Warning - HACK!
# Create both lib directories
mkdir -p $SRC_DIR/build/lib
mkdir -p $SRC_DIR/build/lib64

echo "ONE"
ls $PREFIX/lib/

echo "TWO"
ls $SRC_DIR/build/lib/ || true

echo "THREE"
ls $SRC_DIR/build/lib64/ || true

cp $PREFIX/lib/_ttnn.so $SRC_DIR/build/lib/_ttnn.so || true
cp $PREFIX/lib/_ttnn.so $SRC_DIR/build/lib64/_ttnn.so || true
cp $PREFIX/lib/libtt_metal.so $SRC_DIR/build/lib/libtt_metal.so || true
cp $PREFIX/lib/libtt_metal.so $SRC_DIR/build/lib64/libtt_metal.so || true
cp $PREFIX/lib/libdevice.so $SRC_DIR/build/lib/libdevice.so || true
cp $PREFIX/lib/libdevice.so $SRC_DIR/build/lib64/libdevice.so || true

echo "Starting pip install"

pip install --no-deps $SRC_DIR
