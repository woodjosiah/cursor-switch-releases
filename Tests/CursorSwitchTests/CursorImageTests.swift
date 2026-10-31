import AppKit
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import CursorSwitch

@MainActor
struct CursorImageTests {
    @Test func importBoundsResolutionAndPreservesTransparency() throws {
        let png = try CursorImageImport.normalize(transparentFixture())
        let source = try #require(CGImageSourceCreateWithData(png as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        #expect(image.width == 512)
        #expect(image.height == 256)
        #expect(image.alphaInfo == .last || image.alphaInfo == .premultipliedLast || image.alphaInfo == .first || image.alphaInfo == .premultipliedFirst)
        let bitmap = NSBitmapImageRep(cgImage: image)
        #expect(bitmap.colorAt(x: 0, y: 0)?.alphaComponent == 0)
    }

    @Test func invalidFileIsRejected() {
        #expect(throws: (any Error).self) { try CursorImageImport.normalize(Data("not an image".utf8)) }
    }

    @Test func invisibleImageCannotBeUsedAsCursor() throws {
        let image = NSImage(size: NSSize(width: 20, height: 20), flipped: false) { _ in true }
        let tiff = try #require(image.tiffRepresentation)
        var profile = CursorProfile()
        profile.kind = .image
        profile.imagePNG = try CursorImageImport.normalize(tiff)
        #expect(CursorArtwork.validationMessage(for: profile) != nil)
    }

    @Test func imageAndHotspotPersist() throws {
        var profile = CursorProfile()
        profile.kind = .image
        profile.imagePNG = try CursorImageImport.normalize(transparentFixture())
        profile.imageName = "pointer.png"
        profile.hotspot = .topLeft
        let restored = try JSONDecoder().decode(CursorProfile.self, from: JSONEncoder().encode(profile))
        #expect(restored == profile)
        let rect = CursorArtwork.artworkRect(for: restored)
        #expect(rect.width == 36)
        #expect(rect.height == 18)
        #expect(CursorArtwork.hotspot(for: restored) == rect.origin)
    }

    private func transparentFixture() throws -> Data {
        let context = try #require(CGContext(data: nil, width: 1024, height: 512, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(CGColor(red: 1, green: 0.2, blue: 0.2, alpha: 1))
        context.fill(CGRect(x: 100, y: 100, width: 200, height: 200))
        let image = try #require(context.makeImage())
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return output as Data
    }
}
