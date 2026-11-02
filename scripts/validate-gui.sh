#!/usr/bin/env bash
# Run on the GitHub runner, never inside the shell-free runtime image.
set -euo pipefail
smoke_dir=$(mktemp -d)
cleanup() {
    docker logs arturo-gui-smoke || true
    docker rm -f arturo-gui-smoke >/dev/null 2>&1 || true
    kill "${display_pid:-}" "${callback_pid:-}" 2>/dev/null || true
    rm -rf "$smoke_dir"
}
trap cleanup EXIT
Xvfb :99 -screen 0 1024x768x24 -ac > "$smoke_dir/xvfb.log" 2>&1 &
display_pid=$!
for attempt in {1..30}; do
    [ ! -S /tmp/.X11-unix/X99 ] || break
    sleep 1
done
test -S /tmp/.X11-unix/X99
# The browser subprocess must execute JavaScript and reach this server; merely
# creating a GTK window is not sufficient to pass the test.
python3 - "$smoke_dir" <<'PY' &
import http.server
import pathlib
import sys
root = pathlib.Path(sys.argv[1])
class Callback(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/gui-ready':
            (root / 'ready').touch()
            self.send_response(204)
        else:
            self.send_response(404)
        self.end_headers()
http.server.HTTPServer(('127.0.0.1', 18765), Callback).serve_forever()
PY
callback_pid=$!
cat > "$smoke_dir/gui.art" <<'ART'
webview .title: "Arturo CI" {<html><body><h1>Arturo GUI smoke test</h1><script>window.addEventListener('load', () => { new Image().src = 'http://127.0.0.1:18765/gui-ready'; });</script></body></html>}
ART
docker run -d --name arturo-gui-smoke --network host \
    -e DISPLAY=:99 -e LIBGL_ALWAYS_SOFTWARE=1 \
    -e WEBKIT_DISABLE_DMABUF_RENDERER=1 \
    -e WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v "$smoke_dir:/workspace:ro" arturo:validation gui.art
for attempt in {1..60}; do
    if [ -f "$smoke_dir/ready" ]; then
        echo 'WebKit rendered content and executed the JavaScript callback.'
        exit 0
    fi
    if [ "$(docker inspect arturo-gui-smoke --format '{{.State.Running}}')" != true ]; then
        break
    fi
    sleep 1
done
echo 'WebKit did not complete the GUI callback.' >&2
exit 1
