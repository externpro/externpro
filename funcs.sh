#!/usr/bin/env bash
function init
{
  if  [[ -x .devcontainer/denv.sh ]]; then
    ./.devcontainer/denv.sh
    cat .env
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
function offlinereq
{
  if ! command -v pv >/dev/null; then
    echo "NOTE: install pv before creating an offline container bundle"
    exit 1
  fi
  if ! command -v bzip2 >/dev/null; then
    echo "NOTE: install bzip2 before creating an offline container bundle"
    exit 1
  fi
}
function runreq
{
  check=$(./.devcontainer/check-bpnet-perform.sh)
  bpnet=$(tail -10 .devcontainer/90-bpnet-perform.conf)
  if [[ "${bpnet}" != "${check}" ]]; then
    echo "network performance tuning"
    echo "=========================="
    echo "current linux kernel network settings: (./.devcontainer/check-bpnet-perform.sh)"
    echo "${check}"
    echo "*******"
    echo "desired settings: (.devcontainer/90-bpnet-perform.conf)"
    echo "${bpnet}"
    echo "=========================="
    echo "copying .devcontainer/90-bpnet-perform.conf to /etc/sysctl.d (requires sudo)..."
    sudo cp .devcontainer/90-bpnet-perform.conf /etc/sysctl.d/
    sudo service procps restart
    sudo sysctl --system
    exit 1
  fi
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
function createContainerBundle
{
  offlineDir=.devcontainer/_bld
  if [[ -d ${offlineDir} ]]; then
    rm -rf ${offlineDir}
  fi
  mkdir ${offlineDir}
  if [[ -x .devcontainer/denv.sh ]]; then
    ./.devcontainer/denv.sh
  fi
}
