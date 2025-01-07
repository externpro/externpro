#!/usr/bin/env bash
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
    echo "git-lfs not installed, attempting (requires sudo)..."
    sudo sh -c \
     "mkdir /usr/local/src/lfs \
      && wget -qO- 'https://github.com/git-lfs/git-lfs/releases/download/v2.12.1/git-lfs-linux-amd64-v2.12.1.tar.gz' \
      | tar -xz -C /usr/local/src/lfs \
      && /usr/local/src/lfs/install.sh \
      && rm -rf /usr/local/src/lfs/ \
      && /usr/local/bin/git-lfs install --system"
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
    echo "  git config --global user.email someonehere@sdl.usu.edu"
    echo "verify configuration with"
    echo "  git config --global --list"
    exit 1
  fi
}
function composereq
{
  if ! docker compose version &>/dev/null; then
    echo "docker needs update to support 'docker compose', attempting (requires sudo)..."
    sudo sh -c " \
      mkdir -p /usr/local/lib/docker/cli-plugins \
      && curl -SL 'https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-$(uname -s)-$(uname -m)' \
           -o /usr/local/lib/docker/cli-plugins/docker-compose \
      && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    "
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
  if [[ -f "/proc/driver/nvidia/version" ]]; then
    # Check that driver version is current and supported (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
    currentver=`cat /proc/driver/nvidia/version | head -n1 | cut -d" " -f9`
    requiredver="418.81.07"
    if [ $(echo "$currentver $requiredver" | tr " " "\n" | sort --version-sort | head -n 1) = $currentver ]; then
      echo "Unsupported NVIDIA driver version $currentver < $requiredver, continue anyway? (yes/no)"
      read unsupported
      if [[ ! $unsupported == "yes" ]]; then
        echo "To install appropriate drivers, please consult system admin or see the installation guide https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html"
        exit 1
      fi
    fi
  else
    echo "To run containers with GPU, NVIDIA drivers must be manually installed specific to the hardware."
    echo "NVIDIA drivers do not appear to be installed (required for GPU), continue anyway? (yes/no)"
    read drivers
    if [[ ! $drivers == "yes" ]]; then
      echo "To install appropriate drivers, please consult system admin or see the installation guide https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html"
      exit 1
    fi
  fi
  if ! command -v nvidia-docker &>/dev/null; then
    echo "nvidia-docker not installed, attempting to install (requires sudo)..."
    if [ -d "/etc/apt" ]; then
      curl https://get.docker.com | sh \
       && sudo systemctl --now enable docker
      distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
       && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
       && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
       sudo tee /etc/apt/sources.list.d/nvidia-docker.list
      curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/$distribution/nvidia-container-runtime.list | \
       sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
      sudo apt update
      sudo apt-get install -y nvidia-docker2
      sudo systemctl restart docker
    fi
    if [ -d "/etc/yum.repos.d" ]; then
      distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
      curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | \
        sudo tee /etc/yum.repos.d/nvidia-docker.repo
      sudo yum install -y nvidia-docker2
      sudo yum install -y nvidia-container-toolkit
      sudo systemctl restart docker
    fi
  fi
}
function defUsage
{
  echo "`basename -- $0` usage:"
  echo " -h      display this help message"
  echo "         run the build container (no switches)"
  echo " -b      build docker image(s)"
}
function defOptions
{
  if [ $# -eq 0 ]; then
    buildreq
    init
    docker compose --profile pbld build
    docker compose run --rm bld
    deinit
    exit 0
  fi
  while getopts "bh" opt
  do
    case ${opt} in
      b )
        buildreq
        init
        docker compose --profile pbld build
        deinit
        exit 0
        ;;
      h )
        defUsage
        exit 0
        ;;
      \? )
        defUsage
        exit 0
        ;;
    esac
  done
}
