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

## Open at login and beta 2 (build 3)

- Added the opt-in Open at login setting using `SMAppService.mainApp`; no separate
  persisted Boolean or launch-agent file is used. Approval and registration errors
  are surfaced, and status refreshes when the app becomes active.
- All 24 tests passed, including external consent changes, registration failure,
  pending approval, and enabling/disabling without launch-time registration.
- Live signed-app UI test on macOS 27.2: registration changed the toggle from off
  to on, and unregistering changed it back off. Actual logout/login was not tested.
- Source code and Git history published to the existing GitHub repository at the
  user's request. Tracked history scan found no private keys or credential patterns.
  Existing release assets and the beta 1 signed feed were preserved during merging.
- Xcode initially returned No Accounts. After the user refreshed sign-in, beta 2
  notarization, stapling, and Gatekeeper assessment succeeded.
- Beta 2 universal DMG was signed and published before advancing the signed feed.
  Anonymous download matched the local file exactly: 1,622,055 bytes, SHA-256
  `96731fe11f5b7101cb740499e5078e63d6422b5a495f7763da0a9b368de5ad9a`.
- At the user's request, installed the verified beta 1 DMG into
  `/Applications/Cursor Switch.app` and launched it. Its UI showed
  `Version 1.0.0-beta.1` and the existing cursor preferences. The actual upgrade
  to beta 2 is intentionally left for the user to test.
