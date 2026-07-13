#!/usr/bin/env bash

set -eux

build_directory="$1"
version="$2"
binary_name="$3"

if [ -z "$build_directory" ] || [ -z "$version" ] || [ -z "$binary_name" ];  then
  echo "Usage: $0 <build_directory> <version> <binary_name>"
  echo "Example: $0 syncstorage-rs v0.23.3 syncstorage"
  exit 1
fi


script_dir="$(dirname "$(realpath "$0")")"

# create requirements.txt from venv
rm -rf "$script_dir/../.venv" || true
python3 -m venv "$script_dir/../.venv"
"$script_dir/../.venv/bin/pip" install poetry
VIRTUAL_ENV="$script_dir/../.venv" $script_dir/../.venv/bin/poetry config virtualenvs.create false
VIRTUAL_ENV="$script_dir/../.venv" $script_dir/../.venv/bin/poetry self add poetry-plugin-export
VIRTUAL_ENV="$script_dir/../.venv" $script_dir/../.venv/bin/poetry self update

pushd $build_directory
     VIRTUAL_ENV="$script_dir/../.venv" $script_dir/../.venv/bin/poetry export --no-interaction --without dev --output requirements.txt --without-hashes
popd

pushd $build_directory/tools/tokenserver
    VIRTUAL_ENV="$script_dir/../.venv" $script_dir/../.venv/bin/poetry export --no-interaction --without dev --output ../../requirements-tokenserver.txt --without-hashes
popd

pushd $build_directory
    tar --zstd -cf "$script_dir/../../$binary_name-$version/$binary_name-$version-requirements.tar.zst" requirements.txt requirements-tokenserver.txt
popd

rm -rf "$script_dir/../.venv" || true
