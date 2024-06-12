#!/usr/bin/env bash
if ! command -v pv >/dev/null; then
  echo "NOTE: install pv before saving/compressing an offline docker image"
  exit 1
fi
if ! command -v bzip2 >/dev/null; then
  echo "NOTE: install bzip2 before saving/compressing an offline docker image"
  exit 1
fi
function usage
{
  echo "`basename -- $0` usage:"
  echo " -h            display this help message"
  echo " (no switches) save/compress latest or current tag (if on a tagged commit)"
  echo " -t [tag]      save/compress specified tag"
}
cd "$( dirname "$0" )"
pushd .. > /dev/null
source ./.devcontainer/funcs.sh
if [ $# -eq 0 ]; then
  BPROTAG="$(findVer 'set(buildpro_REV' CMakeLists.txt */toplevel.cmake */*/toplevel.cmake)"
  if [ -z ${BPROTAG} ]; then
    BPROTAG=`git describe --tags`
    if [ -n "$(git status --porcelain --untracked=no)" ] || [[ ${BPROTAG} == *"-g"* ]]; then
      BPROTAG=latest
    fi
  fi
fi
while getopts "t:h" opt
do
  case ${opt} in
    t )
      BPROTAG=$OPTARG
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      usage
      exit 0
      ;;
  esac
done
dkr="$(findVer 'FROM' .devcontainer/rocky85-bld.dockerfile)"
dkr=$(eval echo ${dkr}) # ghcr.io/externpro/buildpro/rocky85-bld:TAG, where TAG=${BPROTAG}
rel=$(echo "${dkr}" | cut -d/ -f4) # rocky85-bld:TAG
rel=${rel/:/-} # parameter expansion substitution
oimg=docker.${rel}.tar.bz2
docker pull ${dkr}
odir=$( pwd )/_bld-offlineImage
if [[ -d ${odir} ]]; then
  rm -rf ${odir}
fi
mkdir ${odir}
cd ${odir}
echo "saving docker image ${dkr}"
echo "to ${odir}/${oimg}..."
docker save ${dkr} | pv -s $(docker image inspect ${dkr} --format='{{.Size}}') | bzip2 > ${oimg}
ldi="#/usr/bin/env bash"
ldi="${ldi}\ncd \"\$( dirname \"\$0\" )\""
ldi="${ldi}\nif [[ ! -f ${oimg} ]]; then"
ldi="${ldi}\n  echo \"error: ${oimg} does not exist\""
ldi="${ldi}\n  exit 0"
ldi="${ldi}\nfi"
ldi="${ldi}\necho \"loading docker image from ${oimg}...\""
ldi="${ldi}\nif ! command -v pv >/dev/null; then"
ldi="${ldi}\n  echo \"NOTE: installing pv will show 'docker load' progress\""
ldi="${ldi}\n  pipe=cat"
ldi="${ldi}\nelse"
ldi="${ldi}\n  pipe=pv"
ldi="${ldi}\nfi"
ldi="${ldi}\n\${pipe} ${oimg} | docker load"
ldi="${ldi}\nif command -v host >/dev/null && host isrhub.sdl.secure | grep \"has address\ >/dev/null; then"
ldi="${ldi}\n  docker push ${dkr}"
ldi="${ldi}\nfi"
echo -e "${ldi}" > ${odir}/loadImage.sh
chmod 755 ${odir}/loadImage.sh
ls -l ${odir}
du -sh ${odir}
popd > /dev/null
