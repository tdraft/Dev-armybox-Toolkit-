#!/bin/sh
set -eu

cargo build --release --target x86_64-unknown-linux-musl "$@"

BIN="target/x86_64-unknown-linux-musl/release/armybox"

# Record size and digest.
wc -c < "$BIN" > armybox.skeleton.size
sha256sum "$BIN" | awk '{print "sha256:"$1}' > armybox.hash

echo "skeleton built: $(cat armybox.skeleton.size) bytes"