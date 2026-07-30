# syncstorage-rs-build
Scripts for building and binary releases of [syncstorage-rs](https://github.com/mozilla-services/syncstorage-rs) for [YunoHost package](https://github.com/YunoHost-Apps/syncserver-rs_ynh).

# Tagging strategy

- `diesel-<version>` are Diesel prebuilts for Bookworm, should work on Trixie as well
- `syncserver-<version>` are SyncServer prebuilts for Bookworm and Trixie

# Prerequisites

- [Rust](https://rust-lang.org/), preferrably installed via [rustup](https://rustup.rs/)
- [Cross-rs](https://github.com/cross-rs/cross), installable via `cargo install cross`
- A container engine of choice, either [Docker](https://www.docker.com/) (cross-preferred) or [Podman](https://podman.io/) (installable via `apt install podman`)

# Initial setup

```sh
git clone https://github.com/YunoHost-Apps/syncstorage-rs-build
cd syncstorage-rs-build
./scripts/setup.sh
```

This will clone this repo and upstream repos of SyncStorage and Diesel

# Building

- Checkout preferred revision/tag/ref under `syncstorage-rs` for syncserver builds
- Run either `./scripts/build-syncserver.sh <version> [--publish]` or `./scripts/build-diesel.sh <upstream_tag> [--publish]`

`build-diesel.sh` will:
- Ensure `./diesel` is cloned from `diesel-rs/diesel`
- Fetch tags and checkout the provided upstream tag in detached HEAD mode
- Build Diesel CLI artifacts via cross-rs (requires docker or podman)
- Optionally publish artifacts as tag `diesel-<upstream_tag>` when called with `--publish` and `gh` is installed/authenticated

`build-syncserver.sh` will:
- Ensure `./syncstorage-rs` is cloned from `mozilla-services/syncstorage-rs`
- Fetch tags and checkout the provided upstream tag in detached HEAD mode
- Build syncserver artifacts for Debian Bookworm and Trixie with `postgres` and `py_verifier` only
- Force `profile.release.debug=0` during builds
- Optionally publish artifacts as tag `syncserver-<upstream_tag>` when called with `--publish` and `gh` is installed/authenticated

If all goes well you'll have a `<target>-<version>` directory with all the artifacts after the script is done.

Both scripts now checkout the requested upstream tag before building.


# Notices

Files under `docker/` are adapted from original `Cross-rs` files available [here](https://github.com/cross-rs/cross/tree/main/docker)