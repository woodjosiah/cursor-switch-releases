import AppKit

@MainActor
protocol ClickMonitoring: AnyObject {
    func start(handler: @escaping @MainActor (CGPoint, Bool) -> Void) -> Bool
    func stop()
}

/// Observes only mouse-down events. Never intercepts input or requests keyboard access.
@MainActor
final class ClickEventMonitor: ClickMonitoring {
    private var globalMonitor: Any?
    private var localMonitor: Any?

    func start(handler: @escaping @MainActor (CGPoint, Bool) -> Void) -> Bool {
        stop()
        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { event in
            // AppKit delivers event-monitor callbacks on the main thread.
            MainActor.assumeIsolated { Self.deliver(event, to: handler) }
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
            MainActor.assumeIsolated { Self.deliver(event, to: handler) }
            return event
        }
        guard globalMonitor != nil, localMonitor != nil else {
            stop()
            return false
        }
        return true
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    private static func deliver(_ event: NSEvent, to handler: @MainActor (CGPoint, Bool) -> Void) {
        let point: CGPoint
        if let window = event.window {
            point = window.convertPoint(toScreen: event.locationInWindow)
        } else if let cgEvent = event.cgEvent, let primary = NSScreen.screens.first {
            // Use the event's position, not the mouse's potentially newer position.
            point = screenPoint(from: cgEvent.location, primaryScreenHeight: primary.frame.height)
        } else {
            point = event.locationInWindow
        }
        let isRightClick = event.type == .rightMouseDown ||
            (event.type == .leftMouseDown && event.modifierFlags.contains(.control))
        handler(point, isRightClick)
    }

    static func screenPoint(from quartzPoint: CGPoint, primaryScreenHeight: CGFloat) -> CGPoint {
        CGPoint(x: quartzPoint.x, y: primaryScreenHeight - quartzPoint.y)
    }
}
