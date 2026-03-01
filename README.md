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

- Checkout preferred revision/tag/ref under the corresponding repo (`syncstorage-rs` for syncserver, `diesel` for Diesel)
- Run eitehr `./scripts/build-syncstorage.sh <version>` or `./scripts/build-diesel.sh <version>`

If all goes well you'll have a `<target>-<version>` directory with all the artifacts after the script is done.

Note that `<version>` is just a string that'll be appended to artifact name, the build scripts does not modify the `git` state.


# Notices

Files under `docker/` are adapted from original `Cross-rs` files available [here](https://github.com/cross-rs/cross/tree/main/docker)