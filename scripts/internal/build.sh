#/usr/bin/env bash

set -e


build_directory="$1"
subdir="$2"
binary_name="$3"
dist="$4"
version="$5"
passthrough_args="${@:6}"


script_dir="$(dirname "$(realpath "$0")")"

if [ -z "$build_directory" ] || [ -z "$binary_name" ] || [ -z "$dist" ] || [ -z "$version" ] || [ -z "$subdir" ];  then
  echo "Usage: $0 <build_directory> <subdir> <binary_name> <dist> <version> [additional cargo arguments]"
  echo "Example: $0 diesel diesel_cli diesel bookworm v2.3.6 --features mysql"
  exit 1
fi

mkdir "$script_dir/../../$binary_name-$version" || true

for arch in x86_64-unknown-linux-gnu i686-unknown-linux-gnu aarch64-unknown-linux-gnu armv7-unknown-linux-gnueabihf; do
  if [ "$dist" == "trixie" ] && [ "$arch" == "i686-unknown-linux-gnu" ]; then
    echo "Skipping i686-unknown-linux-gnu for trixie, not supported"
    continue
  fi
  if [ -f "$script_dir/../../$binary_name-$version/$binary_name-$version-$dist-$arch.zst" ]; then
    echo "Skipping $binary_name-$version-$arch.zst, already exists"
    continue
  fi
  pushd "$build_directory/$subdir" || (echo "Failed to change directory to $build_directory/$subdir" && exit 1)
    # cross clean
    CROSS_CONFIG="$script_dir/../../Cross-$dist.toml" cross build --release --frozen --target "$arch" $passthrough_args
  popd || (echo "Failed to return to previous directory" && exit 1)
  pushd "$build_directory/target/$arch/release" || (echo "Failed to change directory to $build_directory/target/$arch/release" && exit 1)
    zstd -19 -T0 --ultra "$binary_name" -o "$script_dir/../../$binary_name-$version/$binary_name-$version-$dist-$arch.zst"
  popd || (echo "Failed to return to previous directory" && exit 1)
done