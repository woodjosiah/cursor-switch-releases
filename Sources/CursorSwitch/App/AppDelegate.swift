import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let shortcut = GlobalShortcut()
    private var signalSources: [DispatchSourceSignal] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Intentional agent app: settings can become key, but no Dock icon appears.
        NSApp.setActivationPolicy(.accessory)
        UpdateService.shared.start()
        CursorStore.shared.shortcutAvailable = shortcut.register()
        ClickIndicatorStore.shared.start()
        let workspace = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.sessionDidResignActiveNotification,
                     NSWorkspace.screensDidSleepNotification] {
            workspace.addObserver(self, selector: #selector(suspendEffects), name: name, object: nil)
        }
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification,
                     NSWorkspace.screensDidWakeNotification] {
            workspace.addObserver(self, selector: #selector(resumeEffects), name: name, object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(restoreDefault),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        for number in [SIGTERM, SIGINT] {
            signal(number, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: number, queue: .main)
            source.setEventHandler { NSApp.terminate(nil) }
            source.resume()
            signalSources.append(source)
        }
        if !UserDefaults.standard.bool(forKey: "hasLaunched") || CommandLine.arguments.contains("--settings") {
            SettingsWindow.shared.show()
            UserDefaults.standard.set(true, forKey: "hasLaunched")
        }
    }

    @objc private func restoreDefault() {
        CursorStore.shared.selectDefault()
        ClickIndicatorStore.shared.clearPulses()
    }

    @objc private func suspendEffects() {
        restoreDefault()
        ClickIndicatorStore.shared.suspend()
    }

    @objc private func resumeEffects() { ClickIndicatorStore.shared.resume() }

    func applicationWillTerminate(_ notification: Notification) {
        CursorStore.shared.selectDefault()
        ClickIndicatorStore.shared.stop()
        shortcut.unregister()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindow.shared.show()
        return true
    }
}
