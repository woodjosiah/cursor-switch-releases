import SwiftUI
import ServiceManagement

struct LoginItemSettings: View {
    @State private var loginItem = LoginItemService()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Open at login", isOn: $loginItem.isEnabled)
                .toggleStyle(.switch)
            Text("Start Cursor Switch in the menu bar when you sign in.")
                .font(.callout).foregroundStyle(.secondary)
            if loginItem.status == .requiresApproval {
                Text("Allow Cursor Switch in System Settings to enable Open at login.")
                    .font(.callout).foregroundStyle(.secondary)
                Button("Open Login Items Settings…") { loginItem.openLoginSettings() }
            }
            if let message = loginItem.errorMessage {
                Text(message).font(.callout).foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear { loginItem.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            loginItem.refresh()
        }
    }
}
