#!/bin/bash

export WORKDIR=/tmp/cifuzz-workdir

# Make this script idempotent
rm -rf $WORKDIR
mkdir $WORKDIR

git clone https://skia.googlesource.com/skia.git --depth 1 $WORKDIR/skia
CIFUZZ_SCRIPT_PATH=$PWD/cifuzz.bash

pushd $WORKDIR
wget https://raw.githubusercontent.com/google/oss-fuzz/master/projects/skia/skia.diff
wget https://raw.githubusercontent.com/google/oss-fuzz/master/projects/skia/BUILD.gn.diff

pushd skia
./bin/sync
pushd third_party/externals/swiftshader/
git checkout 45510ad8a77862c1ce2e33f0efed41544f5f048b
popd
git apply ../skia.diff
cat ../BUILD.gn.diff >> BUILD.gn
popd

MANUAL_SRC_PATH=$PWD/skia OSS_FUZZ_PROJECT_NAME=skia REPO_NAME=skia COMMIT_SHA=fake $CIFUZZ_SCRIPT_PATH
