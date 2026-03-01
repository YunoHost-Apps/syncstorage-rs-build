#!/usr/bin/env bash

set -e

build_tag="$1"

if [ -z "$build_tag" ]; then
  echo "Usage: $0 <build_tag>"
  echo "Example: $0 v2.3.6"
  exit 1
fi

script_dir="$(dirname "$(realpath "$0")")"

# Build diesel_cli
"$script_dir/internal/build.sh" diesel diesel_cli diesel bookworm "$build_tag" --features mysql --no-default-features