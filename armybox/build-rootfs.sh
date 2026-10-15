#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
STAGING_DIR="$WORKSPACE_DIR/.initramfs"
ARCHIVE="$WORKSPACE_DIR/initramfs.cpio.gz"
APP_BINARY="$SCRIPT_DIR/target/x86_64-unknown-linux-musl/release/armybox"
CPIO="$WORKSPACE_DIR/.tools/cpio/usr/bin/cpio"

if [[ ! -f "$APP_BINARY" ]]; then
    echo "Error: armybox binary not found at $APP_BINARY. Build it first."
    exit 1
fi

if [[ ! -x "$CPIO" ]]; then
    echo "Error: local cpio not found at $CPIO. Extract GNU cpio into .tools/cpio first."
    exit 1
fi

mkdir -p "$STAGING_DIR/bin" "$STAGING_DIR/dev" "$STAGING_DIR/proc" "$STAGING_DIR/sys"
cp "$APP_BINARY" "$STAGING_DIR/bin/armybox"
ln -sfn /bin/armybox "$STAGING_DIR/init"

cd "$STAGING_DIR"
find . -print0 | "$CPIO" --null -o --format=newc | gzip -9 > "$ARCHIVE"

echo "Initramfs built: $ARCHIVE"