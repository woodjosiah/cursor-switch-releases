import SwiftUI
import ServiceManagement

struct LoginItemSettings: View {
    @State private var loginItem = LoginItemService()

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Toggle("Open at login", isOn: $loginItem.isEnabled)
                .toggleStyle(.switch)
                .controlSize(.small)
                .font(.callout)
                .fixedSize()
            if loginItem.status == .requiresApproval {
                Text("Allow Cursor Switch in System Settings to enable Open at login.")
                    .font(.callout).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
