#!/usr/bin/env bash
cd "$( dirname "$0" )"
for img in rocky85-pro rocky85-bld
do
  dfile=../${img}.dockerfile
  awk -v r="${img}" '{gsub(/%BP_REPO%/,r)} 1' bit.head.dockerfile > ${dfile}
  if [[ ${img} == *"-bld"* ]]; then
    cat bit.isrhub.dockerfile >> ${dfile}
    cat bit.user.dockerfile >> ${dfile}
  else
    cat bit.user.dockerfile >> ${dfile}
  fi
  cat bit.tail.dockerfile >> ${dfile}
done
