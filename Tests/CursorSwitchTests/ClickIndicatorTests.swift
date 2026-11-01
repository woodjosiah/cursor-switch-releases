import AppKit
import Testing
@testable import CursorSwitch

@MainActor
struct ClickIndicatorTests {
    private func withStore(_ body: (ClickIndicatorStore, TestClickMonitor, TestClickRenderer, UserDefaults) throws -> Void) rethrows {
        let suite = "ClickIndicatorTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let monitor = TestClickMonitor()
        let renderer = TestClickRenderer()
        let store = ClickIndicatorStore(defaults: defaults, monitor: monitor, renderer: renderer)
        defer { store.stop() }
        try body(store, monitor, renderer, defaults)
    }

    @Test func disabledByDefaultAndOnlyMonitorsWhenStarted() {
        withStore { store, monitor, _, _ in
            #expect(!store.settings.isEnabled)
            store.start()
            #expect(monitor.starts == 0)
            store.settings.isEnabled = true
            #expect(monitor.starts == 1)
            store.start()
            store.settings.size = 72
            #expect(monitor.starts == 1)
        }
    }

    @Test func eventsUseTheirPositionAndLatestSettingsAndStopImmediately() {
        withStore { store, monitor, renderer, _ in
            store.settings.isEnabled = true
            store.start()
            store.settings.size = 93
            let point = CGPoint(x: -130, y: 1800)
            monitor.handler?(point, true)
            #expect(renderer.point == point)
            #expect(renderer.settings?.size == 93)
            #expect(renderer.isRightClick == true)
            let pendingCallback = monitor.handler
            store.settings.isEnabled = false
            #expect(monitor.handler == nil)
            #expect(!renderer.visible)
            pendingCallback?(point, false)
            #expect(renderer.shows == 1)
        }
    }

    @Test func settingsRestoreIndependentlyOfCursorMode() {
        withStore { store, _, _, defaults in
            store.settings.isEnabled = true
            store.settings.usesRightClickColor = true
            store.settings.style = .ripple
            store.settings.size = 120
            store.settings.color = .white
            let restored = ClickIndicatorStore(defaults: defaults, monitor: TestClickMonitor(), renderer: TestClickRenderer())
            #expect(restored.settings == store.settings)
        }
    }

    @Test func suspensionClearsPulsesAndResumesOnlyWhenEnabled() {
        withStore { store, monitor, renderer, _ in
            store.settings.isEnabled = true
            store.start()
            monitor.handler?(.zero, false)
            #expect(renderer.visible)
            store.suspend()
            #expect(!renderer.visible)
            #expect(monitor.handler == nil)
            store.resume()
            #expect(monitor.starts == 2)
            store.suspend()
            store.settings.isEnabled = false
            store.resume()
            #expect(monitor.starts == 2)
            store.stop()
            store.settings.isEnabled = true
            #expect(monitor.starts == 2)
        }
    }

    @Test func failedMonitorCanBeRetried() {
        withStore { store, monitor, _, _ in
            monitor.shouldSucceed = false
            store.settings.isEnabled = true
            store.start()
            #expect(store.errorMessage != nil)
            store.settings.isEnabled = false
            monitor.shouldSucceed = true
            store.settings.isEnabled = true
            #expect(store.errorMessage == nil)
            #expect(monitor.starts == 2)
        }
    }

    @Test func invalidSettingsRecoverWithoutTouchingCursorPreferences() {
        withStore { _, _, _, defaults in
            defaults.set(Data("invalid".utf8), forKey: ClickIndicatorStore.settingsKey)
            let restored = ClickIndicatorStore(defaults: defaults, monitor: TestClickMonitor(), renderer: TestClickRenderer())
            #expect(restored.settings == ClickIndicatorSettings())
        }
        var settings = ClickIndicatorSettings()
        settings.size = .nan
        settings.color = CursorColor(red: 2, green: -1, blue: .infinity)
        #expect(settings.sanitized.size == 48)
        #expect(settings.sanitized.color == CursorColor(red: 1, green: 0, blue: 0))
        settings.size = 500
        #expect(settings.sanitized.size == 120)
        settings.size = -1
        #expect(settings.sanitized.size == 24)
    }

    @Test func secondaryColorIsOptIn() {
        var settings = ClickIndicatorSettings()
        #expect(settings.color(isRightClick: true) == settings.color)
        settings.usesRightClickColor = true
        #expect(settings.color(isRightClick: true) == settings.rightClickColor)
        #expect(settings.color(isRightClick: false) == settings.color)
    }

    @Test func olderSettingsKeepValuesAndDefaultToPulseRing() throws {
        let data = Data(#"{"isEnabled":true,"size":80}"#.utf8)
        let settings = try JSONDecoder().decode(ClickIndicatorSettings.self, from: data)
        #expect(settings.isEnabled)
        #expect(settings.size == 80)
        #expect(settings.style == .pulseRing)
    }

    @Test func quartzCoordinatesMapAcrossDisplays() {
        #expect(ClickEventMonitor.screenPoint(from: CGPoint(x: 40, y: 100), primaryScreenHeight: 1000) == CGPoint(x: 40, y: 900))
        #expect(ClickEventMonitor.screenPoint(from: CGPoint(x: -400, y: -200), primaryScreenHeight: 1000) == CGPoint(x: -400, y: 1200))
        #expect(ClickEventMonitor.screenPoint(from: CGPoint(x: 2100, y: 1300), primaryScreenHeight: 1000) == CGPoint(x: 2100, y: -300))
    }
}

@MainActor
private final class TestClickMonitor: ClickMonitoring {
    var starts = 0
    var shouldSucceed = true
    var handler: (@MainActor (CGPoint, Bool) -> Void)?
    func start(handler: @escaping @MainActor (CGPoint, Bool) -> Void) -> Bool {
        starts += 1
        self.handler = shouldSucceed ? handler : nil
        return shouldSucceed
    }
    func stop() { handler = nil }
}

@MainActor
private final class TestClickRenderer: ClickIndicatorRendering {
    var point: CGPoint?
    var settings: ClickIndicatorSettings?
    var isRightClick: Bool?
    var visible = false
    var shows = 0
    func show(at point: CGPoint, settings: ClickIndicatorSettings, isRightClick: Bool) {
        self.point = point
        self.settings = settings
        self.isRightClick = isRightClick
        visible = true
        shows += 1
    }
    func dismiss() { visible = false }
}
