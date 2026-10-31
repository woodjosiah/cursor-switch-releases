import AppKit

@MainActor
protocol CursorRendering: AnyObject {
    func show(profile: CursorProfile)
    func update(profile: CursorProfile)
    func dismiss()
}

/// A nonactivating, click-through window. Mouse input continues to the app below.
@MainActor
final class CursorOverlay: CursorRendering {
    private var panel: NSPanel?
    private var timer: Timer?
    private var profile = CursorProfile()
    private var hotspot = CGPoint.zero
    private var lastPosition: CGPoint?

    func show(profile: CursorProfile) {
        if panel == nil {
            let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                                backing: .buffered, defer: false)
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            panel.hidesOnDeactivate = false
            panel.isFloatingPanel = true
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.cursorWindow)) - 1)
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .stationary]
            panel.isReleasedWhenClosed = false
            panel.animationBehavior = .none
            panel.setAccessibilityElement(false)
            self.panel = panel
        }
        update(profile: profile)
        panel?.orderFrontRegardless()
        guard timer == nil else { return }
        // Polling only while custom mode is active avoids Input Monitoring permission.
        // No redraw or window transaction occurs while the pointer is stationary.
        let timer = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.trackPointer() }
        }
        timer.tolerance = 0.002
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func update(profile: CursorProfile) {
        self.profile = profile
        guard let panel else { return }
        let image = CursorArtwork.image(for: profile)
        // Raster analysis happens only when artwork changes, never per frame.
        hotspot = CursorArtwork.hotspot(for: profile)
        let view = NSImageView(frame: CGRect(origin: .zero, size: image.size))
        view.image = image
        view.imageScaling = .scaleNone
        view.setAccessibilityElement(false)
        panel.contentView = view
        panel.setContentSize(image.size)
        lastPosition = nil
        trackPointer()
    }

    func dismiss() {
        timer?.invalidate()
        timer = nil
        panel?.orderOut(nil)
        lastPosition = nil
    }

    private func trackPointer() {
        guard let panel else { return }
        let location = NSEvent.mouseLocation
        guard location != lastPosition else { return }
        lastPosition = location
        panel.setFrameOrigin(Self.origin(pointer: location, imageHeight: panel.frame.height,
                                         hotspot: hotspot))
    }

    /// AppKit uses bottom-left screen coordinates; artwork hotspots use top-left.
    static func origin(pointer: CGPoint, imageHeight: CGFloat, hotspot: CGPoint) -> CGPoint {
        CGPoint(x: pointer.x - hotspot.x, y: pointer.y - imageHeight + hotspot.y)
    }
}
