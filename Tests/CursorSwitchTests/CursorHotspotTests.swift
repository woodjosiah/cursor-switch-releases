import AppKit
import Testing
@testable import CursorSwitch

@MainActor
struct CursorHotspotTests {
    @Test func ignoresTransparentPaddingAndFindsOffsetTip() throws {
        // The visible tip is deliberately far from both the center and top-left.
        let image = NSImage(size: NSSize(width: 40, height: 40), flipped: true) { _ in
            NSColor.red.setFill()
            NSBezierPath(rect: CGRect(x: 25, y: 9, width: 2, height: 20)).fill()
            return true
        }
        let point = try #require(CursorHotspotDetector.topmostVisiblePoint(in: image))
        #expect(abs(point.x - 26) < 0.6)
        #expect(abs(point.y - 9) < 0.6)
    }

    @Test func choosesVisiblePixelInsteadOfGapBetweenTwoTips() throws {
        let image = NSImage(size: NSSize(width: 40, height: 40), flipped: true) { _ in
            NSColor.red.setFill()
            NSBezierPath(rect: CGRect(x: 5, y: 10, width: 3, height: 20)).fill()
            NSBezierPath(rect: CGRect(x: 30, y: 10, width: 3, height: 20)).fill()
            return true
        }
        let point = try #require(CursorHotspotDetector.topmostVisiblePoint(in: image))
        #expect((5...8).contains(point.x) || (30...33).contains(point.x))
        #expect(abs(point.y - 10) < 0.6)
    }

    @Test func fullyTransparentArtworkHasNoHotspot() {
        let image = NSImage(size: NSSize(width: 20, height: 20), flipped: true) { _ in true }
        #expect(CursorHotspotDetector.topmostVisiblePoint(in: image) == nil)
    }

    @Test func pointingHandUsesFingertipInsteadOfCenter() throws {
        var profile = CursorProfile()
        profile.kind = .symbol
        profile.symbolName = "hand.point.up.fill"
        profile.size = 90
        let point = CursorArtwork.hotspot(for: profile)
        let bounds = CursorArtwork.artworkRect(for: profile)
        #expect(point.y < bounds.midY)
        #expect(point.x > bounds.minX)
        #expect(point.x < bounds.maxX)
    }
}
