import AppKit

/// One renderer supplies both the on-screen pointer and the settings preview.
@MainActor
enum CursorArtwork {
    static let padding: CGFloat = 4

    static func hotspot(for profile: CursorProfile) -> CGPoint {
        if profile.hotspot == .automatic,
           let point = CursorHotspotDetector.topmostVisiblePoint(in: image(for: profile)) {
            return point
        }
        let point = profile.hotspot.normalizedPoint
        let rect = artworkRect(for: profile)
        return CGPoint(x: rect.minX + rect.width * point.x, y: rect.minY + rect.height * point.y)
    }

    static func validationMessage(for profile: CursorProfile) -> String? {
        switch profile.kind {
        case .shape: nil
        case .symbol:
            NSImage(systemSymbolName: profile.symbolName, accessibilityDescription: nil) == nil
                ? "Choose a symbol from the list, or enter a valid symbol name." : nil
        case .emoji:
            profile.emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Enter an emoji for your cursor." : nil
        case .image:
            imageValidationMessage(for: profile)
        }
    }

    private static func imageValidationMessage(for profile: CursorProfile) -> String? {
        guard profile.imagePNG.flatMap({ NSImage(data: $0) }) != nil else {
            return "Drop an image or choose a file for your cursor."
        }
        guard CursorHotspotDetector.topmostVisiblePoint(in: image(for: profile)) != nil else {
            return "This image is fully transparent. Choose an image with a visible cursor."
        }
        return nil
    }

    static func image(for profile: CursorProfile) -> NSImage {
        if profile.kind != .shape { return customImage(for: profile) }
        if profile.shape == .hand { return PointingHandArtwork.image(for: profile) }
        let side = profile.size + padding * 2
        let path = path(for: profile.shape, size: profile.size)
        let fill = profile.fill.nsColor
        let outline = profile.outline.nsColor
        return NSImage(size: CGSize(width: side, height: side), flipped: true) { _ in
            let transform = AffineTransform(translationByX: padding, byY: padding)
            path.transform(using: transform)
            path.lineWidth = max(1.5, profile.size / 18)
            path.lineJoinStyle = .round
            outline.setStroke()
            fill.setFill()
            path.fill()
            path.stroke()
            // The drawing closure may be invoked again at another display scale.
            path.transform(using: AffineTransform(translationByX: -padding, byY: -padding))
            return true
        }
    }

    static func artworkRect(for profile: CursorProfile) -> CGRect {
        var sourceSize = CGSize(width: profile.size, height: profile.size)
        if profile.kind == .shape, profile.shape == .hand {
            sourceSize = NSCursor.pointingHand.image.size
        } else if profile.kind == .image, let data = profile.imagePNG, let image = NSImage(data: data) {
            sourceSize = image.size
        } else if profile.kind == .symbol,
                  let image = NSImage(systemSymbolName: profile.symbolName, accessibilityDescription: nil) {
            sourceSize = image.size
        }
        let scale = profile.size / max(sourceSize.width, sourceSize.height, 1)
        let width = sourceSize.width * scale
        let height = sourceSize.height * scale
        return CGRect(x: padding + (profile.size - width) / 2,
                      y: padding + (profile.size - height) / 2, width: width, height: height)
    }

    private static func customImage(for profile: CursorProfile) -> NSImage {
        let side = profile.size + padding * 2
        let rect = artworkRect(for: profile)
        var artwork: NSImage?
        if profile.kind == .symbol {
            let configuration = NSImage.SymbolConfiguration(pointSize: profile.size, weight: .regular)
                .applying(NSImage.SymbolConfiguration(paletteColors: [profile.fill.nsColor]))
            artwork = NSImage(systemSymbolName: profile.symbolName, accessibilityDescription: nil)?
                .withSymbolConfiguration(configuration)
        } else if profile.kind == .image, let data = profile.imagePNG {
            artwork = NSImage(data: data)
        }
        let source = artwork
        return NSImage(size: CGSize(width: side, height: side), flipped: true) { _ in
            if profile.kind == .emoji {
                let text = NSAttributedString(string: profile.emoji, attributes: [
                    .font: NSFont.systemFont(ofSize: profile.size * 0.82)
                ])
                let size = text.size()
                text.draw(at: CGPoint(x: (side - size.width) / 2, y: (side - size.height) / 2))
            } else {
                source?.draw(in: rect, from: .zero, operation: .sourceOver,
                             fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
            }
            return true
        }
    }

    private static func path(for shape: CursorShape, size: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        let inset: CGFloat = 2
        let extent = size - inset * 2
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: inset + x * extent, y: inset + y * extent)
        }
        switch shape {
        case .hand:
            // The native hand is rendered by PointingHandArtwork above.
            break
        case .arrow:
            let points: [(CGFloat, CGFloat)] = [(0, 0), (0.76, 0.60), (0.45, 0.64),
                (0.66, 0.94), (0.48, 1), (0.29, 0.70), (0.07, 0.93)]
            path.move(to: point(points[0].0, points[0].1))
            for (x, y) in points.dropFirst() { path.line(to: point(x, y)) }
            path.close()
        case .circle:
            path.appendOval(in: CGRect(x: inset, y: inset, width: extent, height: extent))
        case .diamond:
            path.move(to: point(0.5, 0))
            path.line(to: point(1, 0.5))
            path.line(to: point(0.5, 1))
            path.line(to: point(0, 0.5))
            path.close()
        case .crosshair:
            let points: [(CGFloat, CGFloat)] = [(0.42, 0), (0.58, 0), (0.58, 0.42),
                (1, 0.42), (1, 0.58), (0.58, 0.58), (0.58, 1), (0.42, 1),
                (0.42, 0.58), (0, 0.58), (0, 0.42), (0.42, 0.42)]
            path.move(to: point(points[0].0, points[0].1))
            for (x, y) in points.dropFirst() { path.line(to: point(x, y)) }
            path.close()
        }
        return path
    }
}
