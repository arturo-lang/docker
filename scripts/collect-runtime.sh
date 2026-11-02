#!/bin/sh
# Run only inside the Debian builder. Resolve runtime packages independently of
# builder packages, including libraries loaded dynamically (not visible to ldd).
set -eu
mkdir -p /runtime /runtime-debs/partial
apt-get -y --download-only --no-install-recommends \
    -o Dir::State::status=/dev/null \
    -o Dir::Cache::archives=/runtime-debs \
    install "$@"
for archive in /runtime-debs/*.deb; do
    dpkg-deb --extract "$archive" /runtime
done
# Keep shared libraries, WebKit subprocesses, data, schemas and licenses. The
# final image copies these directories only, leaving package tools and shells out.
mkdir -p /runtime/usr/lib /runtime/usr/share /runtime/etc/fonts
rm -rf /runtime/usr/share/man /runtime/usr/share/lintian
