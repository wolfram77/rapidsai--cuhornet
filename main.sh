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
  wget https://github.com/rapidsai/rmm/archive/refs/tags/v23.08.00.tar.gz
  mv v23.08.00.tar.gz rmm-23.08.00.tar.gz
  tar -xzf rmm-23.08.00.tar.gz
  mv rmm-23.08.00 rmm
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

# Run Hornet PageRank on all graphs
runHornet() {
stdbuf --output=L ./pr ~/Data/indochina-2004.mtx  2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/arabic-2005.mtx     2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/uk-2005.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/webbase-2001.mtx    2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/it-2004.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/sk-2005.mtx         2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/com-LiveJournal.mtx 2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/com-Orkut.mtx       2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/asia_osm.mtx        2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/europe_osm.mtx      2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/kmer_A2a.mtx        2>&1 | tee -a "$out"
stdbuf --output=L ./pr ~/Data/kmer_V1r.mtx        2>&1 | tee -a "$out"
}

# Run Hornet PageRank 5 times
for i in {1..5}; do
  runHornet
done

# Signal completion
curl -X POST "https://maker.ifttt.com/trigger/puzzlef/with/key/${IFTTT_KEY}?value1=$src$1"
