#!/usr/bin/env bash
src="rapidsai--cuhornet"
out="$HOME/Logs/$src$1.log"
ulimit -s unlimited
printf "" > "$out"

# Download source code
if [[ "$DOWNLOAD" != "0" ]]; then
  rm -rf $src
  git clone --recursive https://github.com/wolfram77/$src
  cd $src
  git checkout for-pagerank-cuda-dynamic
  mkdir -p externals
  cd externals
  wget https://github.com/rapidsai/rmm/archive/refs/tags/v23.08.00.tar.gz
  mv v23.08.00.tar.gz rmm-23.08.00.tar.gz
  tar -xzf rmm-23.08.00.tar.gz
  mv rmm-23.08.00 rmm
  cd ../..
fi
cd $src

# Install gve.sh
npm i -g gve.sh

# Build
export RMM_INCLUDE=$PWD/externals/rmm/include
cd hornet/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32
cd ../..
cd hornetsnest/build
cmake -DRMM_INCLUDE=$RMM_INCLUDE ..
make -j32
if [[ "$?" -ne "0" ]]; then
  echo "Compilation failed!"
  exit 1
fi

# Run Hornet PageRank on one graph
runOne() {
  gve add-self-loops -i "$1.mtx" -o "$1.self.mtx"
  stdbuf --output=L ./pr "$1.self.mtx"  2>&1 | tee -a "$out"
  stdbuf --output=L printf "\n\n"            | tee -a "$out"
  rm -f "$1.self.mtx"
}

# Run on each graph
runAll() {
  runOne ~/Data/indochina-2004
  runOne ~/Data/uk-2002
  runOne ~/Data/arabic-2005
  runOne ~/Data/uk-2005
  runOne ~/Data/webbase-2001
  runOne ~/Data/it-2004
  runOne ~/Data/sk-2005
  runOne ~/Data/com-LiveJournal
  runOne ~/Data/com-Orkut
  runOne ~/Data/asia_osm
  runOne ~/Data/europe_osm
  runOne ~/Data/kmer_A2a
  runOne ~/Data/kmer_V1r
}

# Run 5 times
for i in {1..5}; do
  runAll
done

# Signal completion
curl -X POST "https://maker.ifttt.com/trigger/puzzlef/with/key/${IFTTT_KEY}?value1=$src$1"
