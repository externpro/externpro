#!/usr/bin/env bash
cd "$( dirname "$0" )"
for img in centos7-run rocky85-pro rocky85-bld rocky85-dev
do
  dfile=../.devcontainer/${img}.dockerfile
  awk -v r="${img}" '{gsub(/%BP_REPO%/,r)} 1' bit.head.dockerfile > ${dfile}
  if [[ ${img} == *"-bld"* ]]; then
    cat bit.offline.dockerfile >> ${dfile}
    cat bit.browsers.dockerfile >> ${dfile}
    cat bit.isrhub.dockerfile >> ${dfile}
    cat bit.user.dockerfile >> ${dfile}
  elif [[ ${img} == *"-run"* ]]; then
    cat bit.user.dockerfile >> ${dfile}
    cat bit.run.dockerfile >> ${dfile}
  elif [[ ${img} == *"-dev"* ]]; then
    cat bit.isrhub.dockerfile >> ${dfile}
    cat bit.user.dockerfile >> ${dfile}
    cat bit.run.dockerfile >> ${dfile}
  else
    cat bit.user.dockerfile >> ${dfile}
  fi
  cat bit.tail.dockerfile >> ${dfile}
done
