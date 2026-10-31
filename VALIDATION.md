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

This is a locally built, ad-hoc-signed app, not a notarized distribution.
