import Observation
import ServiceManagement

@MainActor
@Observable
final class LoginItemService {
    private(set) var status: SMAppService.Status = .notRegistered
    private(set) var errorMessage: String?

    @ObservationIgnored private let readStatus: () -> SMAppService.Status
    @ObservationIgnored private let register: () throws -> Void
    @ObservationIgnored private let unregister: () throws -> Void

    init(
        readStatus: @escaping () -> SMAppService.Status = { SMAppService.mainApp.status },
        register: @escaping () throws -> Void = { try SMAppService.mainApp.register() },
        unregister: @escaping () throws -> Void = { try SMAppService.mainApp.unregister() }
    ) {
        self.readStatus = readStatus
        self.register = register
        self.unregister = unregister
        refresh()
    }

    // macOS owns this preference. Do not persist a separate Boolean that could
    // disagree with consent revoked in System Settings.
    var isEnabled: Bool {
        get { status == .enabled }
        set { setEnabled(newValue) }
    }

    func refresh() {
        let actual = readStatus()
        if actual != status { errorMessage = nil }
        status = actual
    }

    func setEnabled(_ enabled: Bool) {
        errorMessage = nil
        refresh()
        guard enabled != isEnabled else { return }
        // Re-registering a service with revoked consent does not grant consent.
        // Keep the toggle off and expose the System Settings approval action.
        guard !(enabled && status == .requiresApproval) else { return }
        do {
            if enabled { try register() } else { try unregister() }
            refresh()
        } catch {
            refresh()
            errorMessage = "Couldn’t change Open at login: \(error.localizedDescription)"
        }
    }

    func openLoginSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
