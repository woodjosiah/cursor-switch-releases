import AppKit

@MainActor
enum CursorHotspotDetector {
    /// Scan the final artwork, including symbol/emoji outlines and image alpha.
    /// Ignore near-transparent antialiasing; choose an actual visible pixel on
    /// the first occupied row, nearest that row's horizontal midpoint.
    static func topmostVisiblePoint(in image: NSImage) -> CGPoint? {
        let scale: CGFloat = 2
        let width = max(1, Int(ceil(image.size.width * scale)))
        let height = max(1, Int(ceil(image.size.height * scale)))
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width,
            pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: width * 4, bitsPerPixel: 32),
              let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.cgContext.scaleBy(x: scale, y: scale)
        image.draw(in: CGRect(origin: .zero, size: image.size), from: .zero,
                   operation: .copy, fraction: 1, respectFlipped: false, hints: nil)
        NSGraphicsContext.restoreGraphicsState()

        for y in 0..<height {
            var occupied: [Int] = []
            for x in 0..<width where (bitmap.colorAt(x: x, y: y)?.alphaComponent ?? 0) >= 0.12 {
                occupied.append(x)
            }
            if let first = occupied.first, let last = occupied.last {
                let center = Double(first + last) / 2
                let x = occupied.min { abs(Double($0) - center) < abs(Double($1) - center) } ?? first
                return CGPoint(x: (CGFloat(x) + 0.5) / scale, y: (CGFloat(y) + 0.5) / scale)
            }
        }
        return nil
    }
}
