#!/usr/bin/env bash
set -e
prefix=$(cd "$(dirname "$0")/.." && pwd)

opts=()
if ! tty >/dev/null 2>&1; then
  opts+=(--quiet --no-self-upgrade)
fi
"$prefix/libexec/certbot-auto" renew "${opts[@]}" "$@"
