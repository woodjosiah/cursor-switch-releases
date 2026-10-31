# Cursor Switch Beta

A small macOS menu bar utility for switching between your normal pointer and a
custom cursor. Choose shapes, SF Symbols, emoji, or your own transparent image.

## Install

1. Download the DMG from [Releases](https://github.com/woodjosiah/cursor-switch-releases/releases).
2. Open it and drag **Cursor Switch** to **Applications**.
3. Eject the disk image, then open Cursor Switch from Applications.

Look for the cursor icon in your menu bar. There is intentionally no Dock icon.
Use **Customize…** to edit your alternate cursor. **Control–Option–Command–C**
switches cursors, and quitting restores your normal macOS pointer.

Requires **macOS 15 or newer**, on an Apple Silicon or Intel Mac.

## Updates and feedback

Use **Check for Updates…** in the menu bar to install newer beta builds through
Sparkle. Update downloads and the update feed are cryptographically signed.

Please [open an issue](https://github.com/woodjosiah/cursor-switch-releases/issues)
with your macOS version and a short description if something goes wrong. Avoid
including personal information in screenshots.

Custom cursors keep the same appearance over text and links. This beta uses a
macOS compatibility layer for system-wide cursor replacement, so fullscreen and
multi-display behavior may vary between macOS releases.

This repository includes the app's Swift source, tests, build scripts, release
downloads, and signed update feed. See the main README for build instructions.
