#!/usr/bin/env bash
set -euo pipefail
max_attempts=6
attempt=1
delay=5
out=
while true; do
  set +e
  out=$("$@" 2>&1)
  rc=$?
  set -e
  if [ $rc -eq 0 ]; then
    printf '%s' "$out"
    exit 0
  fi
  if echo "$out" | grep -q "HTTP 429"; then
    if [ $attempt -ge $max_attempts ]; then
      printf '%s\n' "$out" >&2
      exit $rc
    fi
    printf '%s\n' "$out" >&2
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 2))
    continue
  fi
  printf '%s\n' "$out" >&2
  exit $rc
done
