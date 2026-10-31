import ServiceManagement
import Testing
@testable import CursorSwitch

@MainActor
struct LoginItemServiceTests {
    @Test func refreshReflectsConsentRevokedOutsideApp() {
        var systemStatus: SMAppService.Status = .enabled
        let service = LoginItemService(readStatus: { systemStatus }, register: {}, unregister: {})
        #expect(service.isEnabled)
        systemStatus = .requiresApproval
        service.refresh()
        #expect(!service.isEnabled)
        #expect(service.status == .requiresApproval)
    }

    @Test func registrationFailureDoesNotLeaveToggleEnabled() {
        struct Failure: Error {}
        let service = LoginItemService(readStatus: { .notRegistered }, register: { throw Failure() }, unregister: {})
        service.isEnabled = true
        #expect(!service.isEnabled)
        #expect(service.errorMessage != nil)
    }

    @Test func pendingApprovalIsNotReportedAsEnabledOrRegisteredAgain() {
        var systemStatus: SMAppService.Status = .notRegistered
        var registrations = 0
        let service = LoginItemService(readStatus: { systemStatus }, register: {
            registrations += 1
            systemStatus = .requiresApproval
        }, unregister: {})
        service.isEnabled = true
        #expect(!service.isEnabled)
        #expect(service.status == .requiresApproval)
        service.isEnabled = true
        #expect(registrations == 1)
    }

    @Test func enablingAndDisablingUseSystemStateWithoutLaunchSideEffects() {
        var systemStatus: SMAppService.Status = .notRegistered
        var registrations = 0
        let service = LoginItemService(readStatus: { systemStatus }, register: {
            registrations += 1
            systemStatus = .enabled
        }, unregister: { systemStatus = .notRegistered })
        #expect(registrations == 0)
        service.isEnabled = true
        #expect(service.isEnabled)
        service.isEnabled = false
        #expect(!service.isEnabled)
        #expect(systemStatus == .notRegistered)
    }
}
