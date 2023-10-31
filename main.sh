#!/usr/bin/env bash
src="rapidsai--cuhornet"
out="$HOME/Logs/$src.log"
ulimit -s unlimited
printf "" > "$out"

# Download source code
if [[ "$DOWNLOAD" != "0" ]]; then
  rm -rf $src
  git clone --recursive https://github.com/wolfram77/$src
  mkdir -p $src/externals
  cd $src/externals
  git clone --recursive https://github.com/rapidsai/rmm
  cd ../..
fi
cd $src

# Build and run
export RMM_INCLUDE=$PWD/externals/rmm/include
cd hornet/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32
cd ../..
cd hornetsnest/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32
