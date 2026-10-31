import AppKit
import Observation
@preconcurrency import Sparkle

@MainActor
@Observable
final class UpdateService: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    static let shared = UpdateService()

    private(set) var isConfigured = false
    private(set) var canCheckForUpdates = false
    private(set) var availableVersion: String?

    @ObservationIgnored private var controller: SPUStandardUpdaterController?
    @ObservationIgnored private var observation: NSKeyValueObservation?

    func start() {
        guard controller == nil,
              Bundle.main.object(forInfoDictionaryKey: "CSUpdatesEnabled") as? Bool == true,
              let feed = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
              URL(string: feed)?.scheme == "https",
              let publicKey = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
              Data(base64Encoded: publicKey)?.count == 32 else { return }

        let controller = SPUStandardUpdaterController(startingUpdater: false,
            updaterDelegate: self, userDriverDelegate: self)
        self.controller = controller
        isConfigured = true
        observation = controller.updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] _, change in
            let enabled = change.newValue ?? false
            Task { @MainActor in self?.canCheckForUpdates = enabled }
        }
        controller.startUpdater()
    }

    func checkForUpdates() {
        guard canCheckForUpdates else { return }
        NSApp.activate()
        controller?.checkForUpdates(nil)
    }

    // Use the menu bar as the update reminder. Never create a Dock icon.
    nonisolated var supportsGentleScheduledUpdateReminders: Bool { true }

    nonisolated func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool) -> Bool {
        immediateFocus
    }

    nonisolated func standardUserDriverWillHandleShowingUpdate(_ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        let version = handleShowingUpdate ? nil : update.displayVersionString
        Task { @MainActor [weak self] in self?.availableVersion = version }
    }

    nonisolated func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        Task { @MainActor [weak self] in self?.availableVersion = nil }
    }

    nonisolated func standardUserDriverWillFinishUpdateSession() {
        Task { @MainActor [weak self] in self?.availableVersion = nil }
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        CursorStore.shared.selectDefault()
    }
}
