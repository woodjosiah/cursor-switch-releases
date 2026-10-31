import AppKit
import Testing
@testable import CursorSwitch

@MainActor
struct PointingHandTests {
    @Test func handRendersVisibleArtworkAndFindsFingertip() throws {
        var profile = CursorProfile()
        profile.shape = .hand
        profile.size = 96
        let image = CursorArtwork.image(for: profile)
        #expect(image.size == NSSize(width: 104, height: 104))
        let tip = try #require(CursorHotspotDetector.topmostVisiblePoint(in: image))
        #expect(tip.y < image.size.height / 2)
        #expect(CursorArtwork.hotspot(for: profile) == tip)
    }

    @Test func handPreservesShapeSelectionAndRecolorsArtwork() throws {
        var profile = CursorProfile()
        profile.shape = .hand
        let encoded = try JSONEncoder().encode(profile)
        #expect(try JSONDecoder().decode(CursorProfile.self, from: encoded).shape == .hand)
        let first = try #require(CursorArtwork.image(for: profile).tiffRepresentation)
        profile.fill = CursorColor(red: 0, green: 0.4, blue: 1)
        let second = try #require(CursorArtwork.image(for: profile).tiffRepresentation)
        #expect(first != second)
    }
}
