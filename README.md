# pv-static

Portable builds of [pv](https://www.ivarch.com/programs/pv.shtml), the pipe viewer, which shows the
progress of data through a pipe, built with [zig](https://ziglang.org) as the C toolchain.

- Linux glibc: only glibc is linked dynamically, and only symbols up to glibc 2.17, so the
  binaries run on anything from CentOS 7 onwards
- Linux musl (`--static`): fully static, no runtime dependencies at all (e.g. Alpine)
- macOS: only libSystem is dynamic (it ships with macOS, which has no fully static binaries)

## Prerequisites

- `zig`, GNU make (the `make` 3.81 of macOS is enough), `git`
- `autoconf` (the git tree of pv ships no `configure` script)

## Installation

Clone the repo with submodules (shallow, the history of the vendored projects is not needed):

```shell
git clone --recurse-submodules --shallow-submodules https://github.com/zshsetup/pv-static
cd pv-static
```

## Usage

```shell
./build.sh
```

Output is installed under `dist/`:

- `dist/bin/pv`: the binary; copy it anywhere on your `PATH`
- `dist/share/man/man1/pv.1`: the man page

Pass `--static` for the fully static musl build on Linux (output in `dist-static/`), `--clean` to
remove previous build output first, and `--jobs N` to control parallelism.

To run the smoke tests against the build:

```shell
./tests/run_smoke_tests.sh            # dist/
./tests/run_smoke_tests.sh --static   # dist-static/
```

## Releases

Publishing a GitHub release tagged like the contents of `VERSION`, the tag checked out in
`vendor/pv`, builds and attaches `pv-static-<platform>.tar.gz` for `macos-arm64`,
`linux-amd64`, `linux-arm64`, `linux-musl-amd64`, and `linux-musl-arm64`, together with the sources
they were built from (`pv-static-sources.tar.gz`).

To update a vendored project, check out a new release tag in its submodule, commit it, and update
`VERSION` if it is the main one, e.g.
`git -C vendor/pv fetch --depth 1 origin tag v1.7.24 && git -C vendor/pv checkout v1.7.24`.

## Acknowledgments

This repository builds and vendors the following upstream projects, unmodified, as git
submodules under `vendor/`. Credit goes to their respective authors:

- [pv](https://github.com/a-j-wood/pv) by Andrew Wood and contributors

## License

MIT for the code in this repository. See `NOTICE` for the licenses of the upstream projects and the
resulting binaries, which are Artistic-2.0.
