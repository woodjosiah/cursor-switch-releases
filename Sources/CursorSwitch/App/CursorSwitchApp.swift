import SwiftUI

@main
struct CursorSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var store = CursorStore.shared
    @State private var updates = UpdateService.shared

    var body: some Scene {
        MenuBarExtra {
            CursorMenu(store: store, updates: updates)
        } label: {
            Label(store.isCustom ? "Cursor Switch: Custom" : "Cursor Switch: Default",
                  systemImage: updates.availableVersion != nil ? "arrow.down.circle" : (store.isCustom ? "cursorarrow.rays" : "cursorarrow"))
        }
        .menuBarExtraStyle(.menu)
    }
}
