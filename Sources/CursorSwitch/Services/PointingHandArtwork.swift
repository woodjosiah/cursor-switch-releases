import AppKit

/// Preserve the system link hand's silhouette and finger details while applying
/// the selected fill and outline. Use the highest-resolution native bitmap.
@MainActor
enum PointingHandArtwork {
    static func image(for profile: CursorProfile) -> NSImage {
        let native = NSCursor.pointingHand.image
        let source = native.representations.compactMap { $0 as? NSBitmapImageRep }
            .max { $0.pixelsWide < $1.pixelsWide }
        var artwork = native
        if let cgImage = source?.cgImage,
           let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height,
                bitsPerComponent: 8, bytesPerRow: cgImage.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) {
            // Normalize native cursor color spaces into known premultiplied RGBA.
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
            if let pixels = context.data?.assumingMemoryBound(to: UInt8.self) {
                let fill = [profile.fill.red, profile.fill.green, profile.fill.blue]
                let outline = [profile.outline.red, profile.outline.green, profile.outline.blue]
                for index in stride(from: 0, to: context.bytesPerRow * cgImage.height, by: 4) {
                    let alpha = Double(pixels[index + 3])
                    guard alpha > 0 else { continue }
                    let luminance = min(1, (0.2126 * Double(pixels[index])
                        + 0.7152 * Double(pixels[index + 1]) + 0.0722 * Double(pixels[index + 2])) / alpha)
                    for channel in 0..<3 {
                        let value = (outline[channel] + (fill[channel] - outline[channel]) * luminance) * alpha
                        pixels[index + channel] = UInt8(clamping: Int(value.rounded()))
                    }
                }
                if let tinted = context.makeImage() {
                    artwork = NSImage(cgImage: tinted, size: native.size)
                }
            }
        }
        let rendered = artwork
        let side = profile.size + CursorArtwork.padding * 2
        let rect = CursorArtwork.artworkRect(for: profile)
        return NSImage(size: NSSize(width: side, height: side), flipped: true) { _ in
            rendered.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1,
                          respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
            return true
        }
    }
}
