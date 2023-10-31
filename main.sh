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

# Build
export RMM_INCLUDE=$PWD/externals/rmm/include
cd hornet/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32
cd ../..
cd hornetsnest/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32

# Run on all graphs.
perform-all() {
stdbuf --output=L ./katz ~/Data/indochina-2004.mtx  2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/arabic-2005.mtx     2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/uk-2005.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/webbase-2001.mtx    2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/it-2004.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/sk-2005.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/com-LiveJournal.mtx 2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/com-Orkut.mtx       2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/asia_osm.mtx        2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/europe_osm.mtx      2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/kmer_A2a.mtx        2>&1 | tee -a "$out"
stdbuf --output=L ./katz ~/Data/kmer_V1r.mtx        2>&1 | tee -a "$out"
}
perform-all
perform-all
perform-all
perform-all
perform-all
