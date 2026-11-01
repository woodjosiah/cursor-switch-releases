import AppKit
import Observation

@MainActor
@Observable
final class ClickIndicatorStore {
    static let shared = ClickIndicatorStore()
    static let settingsKey = "clickIndicatorSettings.v1"

    var settings: ClickIndicatorSettings {
        didSet {
            let safe = settings.sanitized
            if safe != settings { settings = safe }
            if let data = try? JSONEncoder().encode(safe) {
                defaults.set(data, forKey: Self.settingsKey)
            }
            reconcileMonitoring()
        }
    }
    private(set) var errorMessage: String?
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let monitor: any ClickMonitoring
    @ObservationIgnored private let renderer: any ClickIndicatorRendering
    @ObservationIgnored private var isStarted = false
    @ObservationIgnored private var isSuspended = false
    @ObservationIgnored private var isMonitoring = false

    init(defaults: UserDefaults = .standard, monitor: (any ClickMonitoring)? = nil,
         renderer: (any ClickIndicatorRendering)? = nil) {
        self.defaults = defaults
        self.monitor = monitor ?? ClickEventMonitor()
        self.renderer = renderer ?? ClickIndicatorOverlay()
        if let data = defaults.data(forKey: Self.settingsKey),
           let saved = try? JSONDecoder().decode(ClickIndicatorSettings.self, from: data) {
            settings = saved.sanitized
        } else {
            settings = ClickIndicatorSettings()
        }
    }

    func start() { isStarted = true; reconcileMonitoring() }
    func stop() { isStarted = false; reconcileMonitoring() }
    func suspend() { isSuspended = true; reconcileMonitoring() }
    func resume() { isSuspended = false; reconcileMonitoring() }
    func clearPulses() { renderer.dismiss() }

    private func reconcileMonitoring() {
        guard isStarted, !isSuspended, settings.isEnabled else {
            monitor.stop()
            isMonitoring = false
            renderer.dismiss()
            errorMessage = nil
            return
        }
        guard !isMonitoring else { return }
        isMonitoring = monitor.start { [weak self] point, isRightClick in
            guard let self, self.isMonitoring, self.settings.isEnabled else { return }
            self.renderer.show(at: point, settings: self.settings, isRightClick: isRightClick)
        }
        errorMessage = isMonitoring ? nil : "Click indicators couldn’t start. Turn Show clicks off and on to try again."
    }
}
