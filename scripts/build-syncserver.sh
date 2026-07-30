#!/usr/bin/env bash

set -euo pipefail

build_tag="$1"
publish_requested=false

if [ -z "$build_tag" ]; then
  echo "Usage: $0 <build_tag> [--publish]"
  echo "Example: $0 0.21.1"
  exit 1
fi

if [ "${2:-}" = "--publish" ]; then
  publish_requested=true
elif [ -n "${2:-}" ]; then
  echo "Unknown argument: $2"
  echo "Usage: $0 <build_tag> [--publish]"
  exit 1
fi

script_dir="$(dirname "$(realpath "$0")")"
repo_root="$(realpath "$script_dir/..")"
syncstorage_dir="$repo_root/syncstorage-rs"
artifact_dir="$repo_root/syncserver-$build_tag"
release_tag="syncserver-$build_tag"

require_container_engine() {
  if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
    echo "A container engine is required by cross-rs. Install docker or podman."
    exit 1
  fi
}

prepare_syncstorage_checkout() {
  if [ ! -d "$syncstorage_dir/.git" ]; then
    git clone https://github.com/mozilla-services/syncstorage-rs "$syncstorage_dir"
  fi

  git -C "$syncstorage_dir" fetch --tags origin
  git -C "$syncstorage_dir" checkout --detach "$build_tag"
}

remove_release_debug_profile() {
  local cargo_toml="$syncstorage_dir/Cargo.toml"

  if [ ! -f "$cargo_toml" ]; then
    echo "Missing file: $cargo_toml"
    exit 1
  fi

  # Remove the release debug profile block so upstream debug symbols are disabled.
  perl -0pi -e 's/\n\[profile\.release\]\n(?:#.*\n)*debug\s*=\s*1\n?//g' "$cargo_toml"
}

publish_artifacts() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "Skipping publish: gh CLI is not installed."
    return
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "Skipping publish: gh CLI is not authenticated."
    return
  fi

  if [ ! -d "$artifact_dir" ]; then
    echo "Skipping publish: artifact directory not found: $artifact_dir"
    return
  fi

  shopt -s nullglob
  local assets=("$artifact_dir"/*.zst)
  shopt -u nullglob

  if [ "${#assets[@]}" -eq 0 ]; then
    echo "Skipping publish: no .zst artifacts were produced."
    return
  fi

  local release_title="SyncServer $build_tag (pgsql)"
  local notes="[syncstorage-rs](https://github.com/mozilla-services/syncstorage-rs) built from [tag $build_tag](https://github.com/mozilla-services/syncstorage-rs/tree/$build_tag), \`postgres\` and \`py_verifier\` only (built on Debian Bookworm and Trixie)."

  if gh release view "$release_tag" >/dev/null 2>&1; then
    gh release edit "$release_tag" --title "$release_title" --notes "$notes"
    gh release upload "$release_tag" "${assets[@]}" --clobber
  else
    gh release create "$release_tag" "${assets[@]}" --title "$release_title" --notes "$notes" --draft
  fi
}

require_container_engine
prepare_syncstorage_checkout
remove_release_debug_profile

"$script_dir/internal/build.sh" syncstorage-rs syncserver syncserver bookworm "$build_tag" --config profile.release.debug=0 --no-default-features --features postgres --features py_verifier
pushd "$syncstorage_dir" || (echo "Failed to change directory to $syncstorage_dir" && exit 1)
  cross clean
popd || (echo "Failed to return to previous directory" && exit 1)
"$script_dir/internal/build.sh" syncstorage-rs syncserver syncserver trixie "$build_tag" --config profile.release.debug=0 --no-default-features --features postgres --features py_verifier

"$script_dir/internal/export-poetry-requirements.sh" "$syncstorage_dir" "$build_tag" syncserver
if [ "$publish_requested" = true ]; then
  publish_artifacts
else
  echo "Skipping publish: pass --publish to upload artifacts to GitHub Releases."
fi
