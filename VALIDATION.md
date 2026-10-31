# Validation

Environment: Apple Silicon, macOS 27.2 (26B118), Swift 6.4.2, Xcode beta toolchain.

- Release build and app-bundle launch: passed.
- `LSUIElement = true`; running process activation policy verified as accessory (1).
- Ad-hoc code signature and Info.plist: validated.
- Unit tests: all 20 passed across four suites.
- Live settings: Default/Custom selection, shape selection, SF Symbol and emoji
  rendering, custom size, and top-visible-pixel selection observed on macOS 27.2.
- Image importer: a transparent local PNG was chosen through the native file
  picker; the correct image and transparency were observed on both preview
  backgrounds. Test image removed afterward. Actual drag gesture not exercised.
- Light/dark settings appearance: offscreen renders inspected; current live
  settings layout also inspected.
- Cross-app pointer motion: user confirmed it works. Both native visibility
  queries reported hidden while Custom was active. User initially saw two cursors,
  then confirmed only the custom cursor remained after UI automation stopped.
  This is consistent with the testing tool's separate pointer indicator.
- Final active style: user's 90-point `hand.point.up.fill`, with **Top visible
  pixel** selected. Rendered pixel detection is covered by regression tests.
- Global shortcut registered without a conflict, but synthetic key input did not
  establish a successful global toggle; physical-key verification remains open.
- Status-item menu interaction, fullscreen, physical multi-display transitions,
  sleep restoration, and drag-and-drop gesture remain manual QA items.

## Shareable beta 1 (build 2)

- Sparkle 2.10.1 added and pinned; all 20 existing tests pass with the integration.
- Universal executable contains arm64 and x86_64 slices, both with minimum macOS 15.0.
- Main app and nested Sparkle code signed with Developer ID Application: Josiah
  Wood (WZ3MCNC4LD), with hardened runtime. Deep/strict signature validation passed.
- App submitted through Xcode for notarization. Stapling and validation passed;
  Gatekeeper returned `accepted`, `source=Notarized Developer ID`.
- The DMG is Developer ID signed and contains the stapled, notarized app. The DMG
  itself was not separately submitted for notarization. Its checksum validates.
- Sparkle archive and appcast signatures generated and verified. Signing private
  key stays in the login Keychain; owner-only temporary exports were removed.
- Published `v1.0.0-beta.1` to the public, downloads-only GitHub repository after
  explicit user approval. The source remains in the local repository.
- Downloaded the public DMG anonymously and compared it byte-for-byte to the
  local artifact. The public signed appcast also matches exactly.
- DMG: 1,596,196 bytes; SHA-256:
  `2fe2d78c3fee8a3b527573ebd007683e1b55d946708683c15759f9368af6567d`.
- Packaged app launched successfully. Live updater UI verification was blocked
  when the Mac locked again; a real upgrade from beta 1 to a later build has not
  yet been exercised. Feed publication/signatures are verified separately.
- Taildrop to `jw-duo` was attempted twice, including after the user opened
  Tailscale. Both attempts returned 502; three Tailscale pings timed out. Delivery
  was not confirmed. A direct public download link was supplied as an alternative.
