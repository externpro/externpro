#!/usr/bin/env bash
cd "$( dirname "$0" )/../.."
OS_NAME=$(uname -s)
if [ -d "_bld-${OS_NAME}/_xpro/xpd" ]; then
  # Clean up any existing temporary backup
  if [ -d "/tmp/xpd_backup" ]; then
    rm -rf "/tmp/xpd_backup"
  fi
  mv "_bld-${OS_NAME}/_xpro/xpd" /tmp/xpd_backup && rm -rf "_bld-${OS_NAME}" && mkdir -p "_bld-${OS_NAME}/_xpro" && mv /tmp/xpd_backup "_bld-${OS_NAME}/_xpro/xpd"
  echo "Successfully cleaned _bld-${OS_NAME} directory while preserving xpd cache"
else
  echo "Error: _bld-${OS_NAME}/_xpro/xpd directory not found"
  exit 1
fi
