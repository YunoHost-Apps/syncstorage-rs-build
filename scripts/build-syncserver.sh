#!/usr/bin/env bash

set -e

build_tag="$1"

if [ -z "$build_tag" ]; then
  echo "Usage: $0 <build_tag>"
  echo "Example: $0 0.21.1"
  exit 1
fi

script_dir="$(dirname "$(realpath "$0")")"

"$script_dir/internal/build.sh" syncstorage-rs syncserver syncserver bookworm "$build_tag" --no-default-features --features 'syncstorage-db/mysql' --features 'py_verifier'
pushd "$script_dir/../syncstorage-rs" || (echo "Failed to change directory to $script_dir/../syncstorage-rs" && exit 1)
  cross clean
popd || (echo "Failed to return to previous directory" && exit 1)
"$script_dir/internal/build.sh" syncstorage-rs syncserver syncserver trixie "$build_tag" --no-default-features --features 'syncstorage-db/mysql' --features 'py_verifier'
