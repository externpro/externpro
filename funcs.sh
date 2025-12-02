#!/usr/bin/env bash
BPROIMG_DEFAULT=rocky8-gcc9
BPROTAG_DEFAULT=25.06
function init
{
  if [[ -x .devcontainer/denv.sh ]]; then
    ./.devcontainer/denv.sh ${BPROIMG}
    cat .env
  fi
}
function deinit
{
  if [ -d .devcontainer/_bldtmp ]; then
    rm -rf .devcontainer/_bldtmp
  fi
}
function findVer
{
  local val=$1
  shift
  for loc in "$@"; do
    if [ -f $loc ]; then
      local gver=`grep "$val" $loc`
      [[ ! -z "$gver" ]] && break
    fi
  done
  local fver=`echo ${gver} | awk '{$1=$1};1' | cut -d " " -f2 | cut -d ")" -f1`
  echo "$fver"
}
function gitlfsreq
{
  if ! command -v git-lfs &>/dev/null; then
    echo "ERROR: git-lfs not installed"
    echo "Install with commands similar to the following:"
    echo "
      mkdir /usr/local/src/lfs \
      && wget -qO- 'https://github.com/git-lfs/git-lfs/releases/download/v2.12.1/git-lfs-linux-amd64-v2.12.1.tar.gz' \
      | tar -xz -C /usr/local/src/lfs \
      && /usr/local/src/lfs/install.sh \
      && rm -rf /usr/local/src/lfs/ \
      && /usr/local/bin/git-lfs install --system
      "
    echo "repo will need to be cloned again for git-lfs to get files stored with lfs"
    exit 1
  fi
  lfscfg=$(git lfs env 2>/dev/null | grep filter-process)
  if [ -z "${lfscfg}" ]; then
    echo "git-lfs not configured, configure /etc/gitconfig with: sudo git lfs install --system"
    git lfs env 2>/dev/null | grep filter.lfs
    echo "repo will need to be cloned again for git-lfs to get files stored with lfs"
    exit 1
  fi
}
function gitcfgreq
{
  if [[ ! -f ~/.gitconfig ]]; then
    echo "~/.gitconfig does not exist, please create with"
    echo "  git config --global user.name \"Someone Here\""
    echo "  git config --global user.email someonehere@acme.org"
    echo "verify configuration with"
    echo "  git config --global --list"
    exit 1
  fi
}
function composereq
{
  if ! docker compose version &>/dev/null; then
    echo "docker needs update to support 'docker compose', please update docker or install docker-compose-plugin..."
    exit 1
  fi
  dcmin="2.24.1"
  dcver=`docker compose version --short`
  if [[ "${dcver}" < "${dcmin}" ]]; then
    echo "docker compose version ${dcver} needs to be at least ${dcmin}, please update or remove old versions in PATH..."
    dcpath=/usr/local/lib/docker/cli-plugins/docker-compose
    if [ -x ${dcpath} ]; then
      dcver=`${dcpath} version --short`
      if [[ "${dcver}" == "2.19.1" ]]; then
        echo "consider removing ${dcpath} version 2.19.1 (used to be installed by this script)"
      fi
    fi
    dcpath=/usr/local/bin/docker-compose
    if [ -x ${dcpath} ]; then
      dcver=`${dcpath} --version`
      if [[ "${dcver}" =~ "1.29.2" ]]; then
        echo "consider removing ${dcpath} version 1.29.2 (used to be installed by this script)"
      fi
    fi
    exit 1
  fi
}
function buildreq
{
  gitcfgreq
  composereq
}
function gpureq
{
  if ! command -v nvidia-container-toolkit 2>&1 > /dev/null; then
    echo "nvidia-container-toolkit (nvidia-docker) not installed"
    if [ -d "/etc/apt" ]; then
      echo "Install with commands similar to the following:"
      echo "
      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      sudo apt-get update
      sudo apt-get install -y nvidia-container-toolkit
      "
    elif [ -d "/etc/yum.repos.d" ]; then
      echo "Install with commands similar to the following:"
      echo "
      curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
        sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
      sudo yum install -y nvidia-container-toolkit
      "
    else
      echo "please determine how to install nvidia-container-toolkit for your package manager"
    fi
  fi
}
function defUsage
{
  echo "`basename -- $0` usage:"
  echo " -h          display this help message"
  echo "             (no switches) run the default build container"
  echo " -b          build the default docker image only (do not run container)"
  echo " -i <img>    build and run using the specified buildpro image <img>"
  echo " -b -i <img> build the specified buildpro image <img> only (do not run container)"
}
# Option parsing:
#   no args = build+run
#   -b = build-only
#   -i <img> sets BPROIMG
#   -b -i = build-only with image
function defOptions
{
  local do_build=0
  local img=""
  while getopts "bhi:" opt
  do
    case ${opt} in
      b )
        do_build=1
        ;;
      i )
        img="${OPTARG}"
        ;;
      h )
        defUsage
        exit 0
        ;;
      \? )
        defUsage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
  if [ $# -gt 0 ]; then
    if [ ${do_build} -eq 1 ] && [ -z "${img}" ] && [ $# -eq 1 ]; then
      echo "Unexpected argument: $1"
      echo "Did you mean: $0 -b -i $1 ?"
    else
      echo "Unexpected argument(s): $*"
    fi
    defUsage
    exit 1
  fi
  if [ -n "${img}" ]; then
    BPROIMG="${img}"
  fi
  buildreq
  init
  docker compose --profile pbld build
  if [ ${do_build} -eq 0 ]; then
    docker compose run --rm bld
  fi
  deinit
  exit 0
}
