# Cursor Switch

A small native macOS menu bar app with a normal pointer and one saved custom
cursor. The Dock icon is intentionally hidden, including while settings are open.

## Use

Open `dist/CursorSwitch.app` after building. Click the cursor icon in the menu bar
and choose **Default** or **Custom**. **Customize…** opens a live light/dark preview
and four cursor sources:

- **Shape:** arrow, circle, crosshair, or diamond, with fill and outline colors.
- **SF Symbol:** enter any installed symbol name, or choose a quick preset; fill is customizable.
- **Emoji:** enter or paste one emoji, use a preset, or open the macOS character picker.
- **Image:** drop a local image into the well or click to choose a file. PNG, JPEG,
  HEIC, TIFF, GIF (first frame), and BMP are supported. Transparency is preserved.

All sources support sizes from 18–96 points. Changes are saved automatically and
update the active cursor. Images up to 20 MB are normalized to a maximum 512-pixel
PNG and saved with the profile; the original file is not needed after import.

**Click point → Top visible pixel** detects the topmost visible pixel in the final
artwork, ignoring transparent padding and faint antialiasing. The click point
lands on the fingertip for a pointing-hand cursor. If a top row has multiple pixels,
it chooses a visible pixel nearest that row's midpoint. Nine manual positions
are also available. Pixel detection runs only when the artwork changes.

**Control–Option–Command–C** toggles modes from any app. Quit from the menu bar.
The app launches in Default mode; the custom style persists between launches.
Default mode uses your existing macOS pointer settings without changing them.

## Build

Requires macOS 15+ and a Swift 6.2+ toolchain. No third-party dependencies.

```sh
./script/build_and_run.sh --verify
swift test
```

The same script powers the Codex **Run** action. Use `--build` to build without
launching, `--logs` / `--telemetry` to stream process logs, or `--debug` for LLDB.
Open `Package.swift` in Xcode for editing. The script stages and ad-hoc signs a
local application at `dist/CursorSwitch.app`; it does not install anything into
Applications or configure launch at login.

## Cursor implementation

macOS does not expose a supported public API for replacing other apps' cursor
shapes. This app draws a small, transparent, nonactivating, click-through panel at
the pointer position and hides the native cursor while Custom is active.
The overlay has a precise shape-dependent click hotspot and follows across
displays and Spaces without intercepting clicks or changing app focus.

`NativeCursorVisibility.swift` is the only private-API boundary. It dynamically
resolves WindowServer's `SetsCursorInBackground` connection property before using
Core Graphics hide/show. If symbol lookup or hiding fails, it removes the overlay,
retains Default mode, and displays an error. No cursor files, accessibility
preferences, or cursor scale are modified.

The public hide/show calls are balanced, including additional hides needed after
another app re-shows the native cursor. A 100 ms visibility check runs only while
Custom is active. Quit, SIGTERM/SIGINT, screen sleep,
session deactivation, and display-configuration changes restore Default mode.
Cursor tracking runs at up to 120 Hz only in Custom mode and skips window updates
when stationary. It uses no input event tap, network service, Accessibility
permission, or Input Monitoring permission.

## Limits

- This is a local, ad-hoc-signed utility, not a notarized or App Store release.
  Private WindowServer behavior can change after macOS updates.
- A custom shape is fixed: it does not turn into the text I-beam, resize handles,
  link hand, or busy cursor. Default mode restores normal contextual cursors.
- Software overlays may lag the hardware pointer, and games, protected system
  surfaces, Mission Control, or fullscreen/display transitions may override them.
- Existing system pointer accessibility settings are preserved, rather than
  reset to factory defaults.

## References

- [Apple: CGDisplayHideCursor](https://developer.apple.com/documentation/coregraphics/cgdisplayhidecursor(_:))
- [Apple: Controlling the Mouse Cursor](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/QuartzDisplayServicesConceptual/Articles/MouseCursor.html)
- [CGSInternal connection declarations](https://github.com/NUIKit/CGSInternal/blob/master/CGSConnection.h)

## Verification

Twenty automated tests cover mode switching, repeated selection, rollback on hide
failure, persistence and migration, malformed preferences, size/color validation,
active preview updates, transparent image import, invalid artwork, multi-scalar
emoji, top-pixel detection, and hotspot math with negative display coordinates.
Live desktop QA is separate
from these tests; see `VALIDATION.md` for the current result.
