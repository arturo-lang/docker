#!/bin/sh
set -eu
case "$(uname -m)" in
    x86_64|amd64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo 'Unsupported architecture' >&2; exit 1 ;;
esac
variant=${1:-full}
case "$variant" in
    full) suffix="-linux-${arch}.zip" ;;
    mini) suffix="-linux-${arch}-mini.zip" ;;
    *) echo 'Expected full or mini' >&2; exit 1 ;;
esac
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
# Resolve the asset from the release itself: the website VERSION file can lag
# behind the archives available on its CDN.
curl -fsSL --retry 3 https://api.github.com/repos/arturo-lang/nightly/releases/latest \
    -o "$work/release.json"
url=$(jq -er --arg suffix "$suffix" \
    '[.assets[] | select(.name | startswith("arturo-nightly.") and endswith($suffix)) | .browser_download_url] | if length == 1 then .[0] else error("Expected one nightly asset") end' \
    "$work/release.json")
curl -fsSL --retry 3 "$url" -o "$work/arturo.zip"
unzip -q "$work/arturo.zip" -d "$work/extracted"
test -f "$work/extracted/arturo"
mkdir -p /root/.arturo/bin
cp "$work/extracted/arturo" /root/.arturo/bin/arturo
chmod +x /root/.arturo/bin/arturo
if [ -f "$work/extracted/cacert.pem" ]; then
    cp "$work/extracted/cacert.pem" /root/.arturo/bin/
fi
