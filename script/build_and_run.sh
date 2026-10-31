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

swift build -c release
BUILD_DIR="$(swift build -c release --show-bin-path)"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cat > "$APP_BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>CursorSwitch</string>
<key>CFBundleIdentifier</key><string>com.josiah.cursorswitch</string>
<key>CFBundleName</key><string>Cursor Switch</string>
<key>CFBundleDisplayName</key><string>Cursor Switch</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>15.0</string>
<key>LSUIElement</key><true/>
<key>NSPrincipalClass</key><string>NSApplication</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
/usr/bin/codesign --force --sign - "$APP_BUNDLE"

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
