#!/usr/bin/env bash
# Usage: ./tests/run_smoke_tests.sh [--static] [--dist DIR]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT_DIR/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --static)
      DIST="$ROOT_DIR/dist-static"
      shift
      ;;
    --dist)
      DIST="$(cd "$2" && pwd)"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

BIN="$DIST/bin/pv"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass() { echo "ok: $*"; }
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

version="$("$BIN" --version | head -n 1)"
echo "$version" | grep -q '^pv ' || fail "pv --version: $version"
pass "$version"

out="$(head -c 100000 /dev/zero | "$BIN" -q | wc -c | tr -d ' ')"
[ "$out" = 100000 ] || fail "pv passed $out bytes of 100000"
pass "passes data through"

out="$(head -c 4096 /dev/zero | "$BIN" -n -s 4096 2>&1 >/dev/null | tail -n 1)"
[ "$out" = 100 ] || fail "numeric progress: $out"
pass "shows the progress"

if [ "$(uname -s)" = Linux ] && ! LC_ALL=C grep -a -q 'ld-musl' "$BIN"; then
  max="$(LC_ALL=C grep -aoh 'GLIBC_2\.[0-9]*' "$BIN" | sort -uV | tail -n 1)" || true
  if [ -n "$max" ]; then
    [ "$(printf '%s\n' "$max" GLIBC_2.17 | sort -V | tail -n 1)" = GLIBC_2.17 ] \
      || fail "needs $max, newer than GLIBC_2.17"
    pass "glibc floor ($max)"
  fi
fi

echo "all smoke tests passed"
