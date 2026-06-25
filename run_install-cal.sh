#!/bin/sh
# Install/upgrade the `cal` calendar CLI from GitHub releases into ~/bin.
# Runs on every `chezmoi apply`: queries the latest release, compares it to the
# installed binary's version, and downloads only when missing or out of date.

set -eu

repo="lepinkainen/cli-cal"
dest="$HOME/bin/cal"

# Latest release tag (e.g. v0.1.0). Skip gracefully if there is no release yet
# or GitHub is unreachable, so a fresh machine's apply never fails on this.
api="https://api.github.com/repos/${repo}/releases/latest"
tag="$(curl -fsSL "$api" 2>/dev/null | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1 || true)"
if [ -z "$tag" ]; then
    echo "cal: no GitHub release found (or offline); skipping" >&2
    exit 0
fi
version="${tag#v}"

# Skip if the installed binary already matches the latest version.
if [ -x "$dest" ]; then
    current="$("$dest" --version 2>/dev/null | awk '{print $2}')"
    if [ "$current" = "$version" ]; then
        echo "cal $version already installed"
        exit 0
    fi
    echo "cal $current installed, upgrading to $version"
fi

# Map uname output to goreleaser's os/arch naming.
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$arch" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
esac

asset="cal_${version}_${os}_${arch}.tar.gz"
base="https://github.com/${repo}/releases/download/${tag}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "Downloading ${asset} ..."
curl -fsSL "${base}/${asset}" -o "$tmpdir/$asset"
curl -fsSL "${base}/checksums.txt" -o "$tmpdir/checksums.txt"

# Verify the SHA-256 checksum before installing.
expected="$(awk -v f="$asset" '$2 == f {print $1}' "$tmpdir/checksums.txt")"
if [ -z "$expected" ]; then
    echo "no checksum found for $asset" >&2
    exit 1
fi
if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$tmpdir/$asset" | awk '{print $1}')"
else
    actual="$(shasum -a 256 "$tmpdir/$asset" | awk '{print $1}')"
fi
if [ "$actual" != "$expected" ]; then
    echo "checksum mismatch for $asset (expected $expected, got $actual)" >&2
    exit 1
fi

mkdir -p "$(dirname "$dest")"
tar -xzf "$tmpdir/$asset" -C "$tmpdir" cal
mv -f "$tmpdir/cal" "$dest"
chmod +x "$dest"
echo "Installed cal $version -> $dest"
