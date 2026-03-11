#!/usr/bin/env sh
# don't replace systemctl on host!
if grep -q docker /proc/1/cgroup; then
  sysctl=/usr/bin/systemctl
  if [ -x ${sysctl} ]; then
    file ${sysctl} | grep -q ELF
    if [ $? -eq 0 ]; then # replace the binary (ELF) systemctl
      sudo mv /usr/bin/systemctl /usr/bin/systemctl.bin # keep the binary systemctl around
      sudo wget -O ${sysctl} https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py
      sudo chmod +x ${sysctl}
    fi
  fi
fi
