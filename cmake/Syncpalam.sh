#!/bin/bash -xe
set -e

rm -rf palam
mkdir palam
rm -rf WorkDir
mkdir WorkDir

baseurl=https://isrhub.usurf.usu.edu/palam/palam/releases/download/v1.11.2.0
downloadAndCompare() {
  curl -L -o palam/$1 $baseurl/$1
  echo "$2 ./palam/$1" > WorkDir/checksum
  sha256sum --check WorkDir/checksum
  rm WorkDir/checksum
}

downloadRepo() {
  git clone https://isrhub.usurf.usu.edu/$1/$2 --bare
  tar -cJf ../palam/$2.tar.xz $2.git
}

echo -e 'v2
{"branch":"development","owner":"palam","projectName":"palam","secureWorkflows":[],"submodules":[],"version":"v1.11.2.0"}
' > palam/info.txt
pushd WorkDir
downloadRepo palam palam
popd

downloadAndCompare Unit_Test_Results.tar.xz 51659829d15a198128c02b481bf3d9363ab42733eca250628e70c94ff9ab32ff
downloadAndCompare palam-v1.11.2.0-win64-devel.tar.xz 8761d810741d07b48188f3ba5adf0c9666a493d5b400d89b99be82fab78b507b
downloadAndCompare palam-v1.11.2.0-Linux-devel.tar.xz 0a2c2a8058d6fb62913d886bd08bbb3b2bc1b3c9d54dc284260c366abad27a4d
tar -cJf palam_v1.11.2.0.tar.xz palam

rm -rf palam
rm -rf WorkDir