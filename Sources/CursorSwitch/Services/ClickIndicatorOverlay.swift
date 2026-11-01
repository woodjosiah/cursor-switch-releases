import AppKit
import QuartzCore
import OSLog

@MainActor
protocol ClickIndicatorRendering: AnyObject {
    func show(at point: CGPoint, settings: ClickIndicatorSettings, isRightClick: Bool)
    func dismiss()
}

/// Short-lived, click-through panels remain at the click location as the mouse moves away.
@MainActor
final class ClickIndicatorOverlay: ClickIndicatorRendering {
    private struct Pulse {
        let id: UUID
        let panel: NSPanel
        let timer: Timer
    }
    private var pulses: [Pulse] = []
    private let logger = Logger(subsystem: "com.josiah.cursorswitch", category: "ClickIndicators")

    func show(at point: CGPoint, settings: ClickIndicatorSettings, isRightClick: Bool) {
        // Bound resources even with very rapid clicks or an automatic clicker.
        if let oldest = pulses.first, pulses.count >= 12 { remove(oldest.id) }
        let settings = settings.sanitized
        let diameter = settings.size
        let side = diameter + 12
        let panel = NSPanel(contentRect: CGRect(x: point.x - side / 2, y: point.y - side / 2,
                                               width: side, height: side),
                            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.cursorWindow)) - 2)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .stationary]
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        panel.setAccessibilityElement(false)

        let view = NSView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        view.wantsLayer = true
        view.setAccessibilityElement(false)
        panel.contentView = view
        panel.orderFrontRegardless()
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let duration = settings.style == .ripple ? 0.7 : 0.55
        addWave(to: view, settings: settings, isRightClick: isRightClick,
                duration: duration, delay: 0, isEcho: false, reduceMotion: reduceMotion)
        if settings.style == .ripple && !reduceMotion {
            addWave(to: view, settings: settings, isRightClick: isRightClick,
                    duration: 0.55, delay: 0.12, isEcho: true, reduceMotion: false)
        }
        let id = UUID()
        let timer = Timer(timeInterval: duration + 0.05, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.remove(id) }
        }
        pulses.append(Pulse(id: id, panel: panel, timer: timer))
        RunLoop.main.add(timer, forMode: .common)
        logger.debug("Displayed click effect: \(settings.style.rawValue, privacy: .public); secondary: \(isRightClick)")
    }

    private func addWave(to view: NSView, settings: ClickIndicatorSettings, isRightClick: Bool,
                         duration: Double, delay: Double, isEcho: Bool, reduceMotion: Bool) {
        let isRipple = settings.style == .ripple
        let color = settings.color(isRightClick: isRightClick).nsColor
        let ring = CAShapeLayer()
        ring.frame = view.bounds
        ring.path = CGPath(ellipseIn: view.bounds.insetBy(dx: 6, dy: 6), transform: nil)
        ring.fillColor = isRipple && !isEcho ? color.withAlphaComponent(0.12).cgColor : NSColor.clear.cgColor
        ring.strokeColor = color.cgColor
        ring.lineWidth = isRipple ? 1.5 : 3
        // Contrast edge keeps the ring visible on both light and dark content.
        ring.shadowColor = NSColor.black.cgColor
        ring.shadowOpacity = 0.4
        ring.shadowRadius = 1.5
        ring.shadowOffset = .zero
        if isRightClick && settings.usesRightClickColor { ring.lineDashPattern = [5, 3] }
        ring.opacity = 0
        view.layer?.addSublayer(ring)
        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = isEcho ? [0.45, 0.35, 0] : (isRipple ? [0.75, 0.6, 0] : [0.95, 0.9, 0])
        fade.keyTimes = [0, 0.25, 1]
        fade.duration = duration
        var animations: [CAAnimation] = [fade]
        if !reduceMotion {
            let expand = CABasicAnimation(keyPath: "transform.scale")
            expand.fromValue = isRipple ? 0.15 : 0.35
            expand.toValue = 1
            expand.duration = duration
            expand.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animations.append(expand)
        }
        let group = CAAnimationGroup()
        group.animations = animations
        group.duration = duration
        group.beginTime = CACurrentMediaTime() + delay
        ring.add(group, forKey: "click")
    }

    func dismiss() {
        for pulse in pulses {
            pulse.timer.invalidate()
            pulse.panel.orderOut(nil)
        }
        pulses.removeAll()
    }

    private func remove(_ id: UUID) {
        guard let index = pulses.firstIndex(where: { $0.id == id }) else { return }
        let pulse = pulses.remove(at: index)
        pulse.timer.invalidate()
        pulse.panel.orderOut(nil)
    }
}
