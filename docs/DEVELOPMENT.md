# Development

Build with Xcode 27 or newer and Python 3. The app supports macOS 15 and later.
Sparkle is pinned in
`Package.swift` and `Package.resolved`.

## Build and test

Run from the repository root:

```sh
./script/build_and_run.sh --verify
swift test
```

Open `Package.swift` in Xcode to edit the project. The build script creates an
ad-hoc-signed app in `dist/`. Use `--build` to build without launching.
Local builds do not enable automatic updates.

## Structure

- `Sources/`: SwiftUI settings and menu bar UI, cursor artwork, platform services,
  and saved preferences.
- `Tests/`: behavior and rendering regression tests.
- `Resources/AppIcon.icon`: the editable layered app icon, compiled by the build script.
- `script/`: build, packaging, and notarization tools. Release tools accept
  signing settings through command-line options or environment variables;
  see their `--help`. Maintainer-specific configuration is kept outside Git.
- `distribution/`: release version metadata and release notes.

System-wide custom cursors use a click-through overlay and a small private macOS
API boundary in `NativeCursorVisibility.swift`. Compatibility can change between
macOS releases. Live testing should cover cursor restoration, fullscreen apps,
multiple displays, login items, and updates in addition to automated tests.

`appcast.xml` is the live, signed Sparkle feed. Publish release assets before
advancing it, and regenerate its signature rather than editing it by hand.
