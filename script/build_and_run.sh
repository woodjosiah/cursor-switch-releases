#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
case "$MODE" in run|--build|--debug|--logs|--telemetry|--verify) ;; *) echo "Usage: $0 [--build|--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;; esac
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="CursorSwitch"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
cd "$ROOT_DIR"

if pgrep -x "$APP_NAME" >/dev/null; then
    pkill -TERM -x "$APP_NAME" || true
    for attempt in {1..30}; do
        if ! pgrep -x "$APP_NAME" >/dev/null; then break; fi
        sleep 0.1
    done
    if pgrep -x "$APP_NAME" >/dev/null; then
        echo "Cursor Switch is still closing. Quit it and try again." >&2
        exit 1
    fi
fi

python3 "$ROOT_DIR/script/build_app.py" --output "$APP_BUNDLE"

case "$MODE" in
    --build) echo "Built: $APP_BUNDLE" ;;
    --debug) /usr/bin/lldb "$APP_BUNDLE/Contents/MacOS/$APP_NAME" ;;
    --logs|--telemetry)
        /usr/bin/open -n "$APP_BUNDLE"
        /usr/bin/log stream --info --style compact --predicate 'process == "CursorSwitch"'
        ;;
    --verify)
        /usr/bin/open -n "$APP_BUNDLE"
        sleep 1
        pgrep -x "$APP_NAME" >/dev/null
        echo "Built and running: $APP_BUNDLE"
        ;;
    run) /usr/bin/open -n "$APP_BUNDLE" ;;
esac
