#/usr/bin/env bash

set -e

build_directory="$1"
binary_name="$2"
version="$3"

script_dir="$(dirname "$(realpath "$0")")"

if [ -z "$build_directory" ] || [ -z "$binary_name" ] || [ -z "$version" ];  then
  echo "Usage: $0 <build_directory> <binary_name> <version>"
  echo "Example: $0 diesel diesel_cli v2.3.6"
  exit 1
fi

mkdir "$script_dir/../$binary_name-$version" || true

for arch in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu armv7-unknown-linux-gnueabihf; do
  pushd "$build_directory/$binary_name/target/$arch/release" || (echo "Failed to change directory to $build_directory/$binary_name/target/$arch/release" && exit 1)
    zstd -19 -T0 --ultra "$binary_name" -o "$script_dir/../$binary_name-$version/$binary_name-$version-$arch.zst"
  popd || (echo "Failed to return to previous directory" && exit 1)
done