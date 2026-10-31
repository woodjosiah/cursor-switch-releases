# Developer documentation

Build, release, and implementation notes for maintaining Cursor Switch. For
installation and everyday use, see the [project README](../README.md).

## Build

Requires macOS 15+ and a Swift 6.2+ toolchain. Sparkle 2.10.1 is pinned in
`Package.swift` / `Package.resolved` for beta updates.

```sh
./script/build_and_run.sh --verify
swift test
```

The same script powers the Codex **Run** action. Use `--build` to build without
launching, `--logs` / `--telemetry` to stream process logs, or `--debug` for LLDB.
Open `Package.swift` in Xcode for editing. The script stages and ad-hoc signs a
local application at `dist/CursorSwitch.app`; it does not install anything into
Applications or configure launch at login.

## Shareable beta builds

Download the beta DMG from
[GitHub Releases](https://github.com/woodjosiah/cursor-switch-releases/releases).
The release app is universal (Apple Silicon + Intel), Developer ID signed, and
Apple-notarized. The signed DMG contains that stapled app and an Applications
shortcut. Copy the app to Applications before running it or checking for updates.

Release builds include **Check for Updates…** in the menu and settings. Sparkle
uses HTTPS and verifies Ed25519 signatures on both the feed and update archive.
Scheduled update reminders stay in the menu bar; the Dock stays hidden. Local
development builds leave the updater disabled to avoid replacing your checkout.

To ship another beta, increase `version` and numeric `build` in
`distribution/release.json`, update `distribution/release-notes.md`, then:

```sh
python3 script/notarize_with_xcode.py
python3 script/package_release.py --prepared-app .release-work/notarized/CursorSwitch.app --notarized-app
```

The first command uses the Developer ID identity and Xcode's existing Apple
account session. If Apple is still processing, resume with `--finish` without
submitting again. A notarytool Keychain profile can alternatively be supplied to
`package_release.py --notary-profile PROFILE` to notarize both the app and DMG.

Release artifacts are in `release-dist/`. Publish the versioned DMG and checksum
as a GitHub Release, then commit the **unmodified signed** `appcast.xml` to the
repository's `main` branch. Publish the asset before updating a live
feed. Never edit the signed XML manually. Keep the signing key in the login
Keychain (account `com.josiah.cursorswitch`) backed up securely; it is not in Git.

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

- Local development builds are ad-hoc signed; packaged beta apps are Developer
  ID signed and notarized. This is not an App Store release. Private WindowServer
  behavior can change after macOS updates.
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

Twenty-four automated tests cover mode switching, repeated selection, rollback on hide
failure, persistence and migration, malformed preferences, size/color validation,
active preview updates, transparent image import, invalid artwork, multi-scalar
emoji, top-pixel detection, hotspot math with negative display coordinates, and
login-item approval, failure, and external state changes.
Live desktop QA is separate
from these tests; see [VALIDATION.md](../VALIDATION.md) for the current result.

## Artwork and click-point details

Images up to 20 MB are normalized to a maximum 512-pixel PNG and stored with the
profile. The original file is not needed after import. GIF imports use the first
frame. Cursor size ranges from 18–96 points.

Automatic click-point detection scans the final rendered artwork, ignoring
transparent padding and faint antialiasing. On the first visible row, it chooses
a visible pixel nearest that row’s midpoint. Detection runs only when the artwork
changes; nine manual positions are also available.
