#!/usr/bin/env bash
function init
{
  if [[ -x .devcontainer/denv.sh ]]; then
    ./.devcontainer/denv.sh
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
  if ! command -v nvidia-container-toolkit 2>&1 > /dev/null; then
    echo "nvidia-docker not installed, attempting to install (requires sudo)..."
    if [ -d "/etc/apt" ]; then
      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
      sudo apt-get update
      sudo apt-get install -y nvidia-container-toolkit
    elif [ -d "/etc/yum.repos.d" ]; then
      curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
        sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
      sudo yum install -y nvidia-container-toolkit
    fi
  fi
}
