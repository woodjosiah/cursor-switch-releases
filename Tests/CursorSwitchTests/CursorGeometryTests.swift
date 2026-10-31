import Foundation
import Testing
@testable import CursorSwitch

@MainActor
struct CursorGeometryTests {
    @Test func arrowTipTracksPointerOnNegativeOriginDisplays() {
        let pointer = CGPoint(x: -1200, y: -600)
        let profile = CursorProfile()
        let hotspot = CursorArtwork.hotspot(for: profile)
        let height = profile.size + CursorArtwork.padding * 2
        let origin = CursorOverlay.origin(pointer: pointer, imageHeight: height, hotspot: hotspot)
        #expect(abs(origin.x + hotspot.x - pointer.x) < 0.001)
        #expect(abs(origin.y + height - hotspot.y - pointer.y) < 0.001)
    }

    @Test(arguments: [CursorShape.circle, .crosshair, .diamond])
    func symmetricShapesClickAtCenter(shape: CursorShape) {
        var profile = CursorProfile()
        profile.shape = shape
        profile.size = 80
        profile.hotspot = .center
        let hotspot = CursorArtwork.hotspot(for: profile)
        #expect(hotspot == CGPoint(x: 44, y: 44))
    }
}
