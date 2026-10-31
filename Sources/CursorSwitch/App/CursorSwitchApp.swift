import SwiftUI

@main
struct CursorSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var store = CursorStore.shared

    var body: some Scene {
        MenuBarExtra {
            CursorMenu(store: store)
        } label: {
            Label(store.isCustom ? "Cursor Switch: Custom" : "Cursor Switch: Default",
                  systemImage: store.isCustom ? "cursorarrow.rays" : "cursorarrow")
        }
        .menuBarExtraStyle(.menu)
    }
}
