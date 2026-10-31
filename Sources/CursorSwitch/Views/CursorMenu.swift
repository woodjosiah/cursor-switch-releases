import SwiftUI

struct CursorMenu: View {
    var store: CursorStore

    var body: some View {
        Text("Cursor Switch")
        Button {
            store.selectDefault()
        } label: {
            Label("Default", systemImage: store.isCustom ? "cursorarrow" : "checkmark")
        }
        Button {
            store.selectCustom()
        } label: {
            Label("Custom", systemImage: store.isCustom ? "checkmark" : "cursorarrow.rays")
        }
        Divider()
        Button("Switch Cursor") { store.toggle() }
            .keyboardShortcut("c", modifiers: [.control, .option, .command])
        Button("Customize…") { SettingsWindow.shared.show() }
            .keyboardShortcut(",")
        if store.errorMessage != nil {
            Button("Couldn’t Switch — Details…") { SettingsWindow.shared.show() }
        }
        Divider()
        Button("Quit Cursor Switch") {
            store.selectDefault()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
