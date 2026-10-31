import SwiftUI

/// Native tab picker: the system owns dragging, refraction, accessibility,
/// and keyboard behavior.
struct CursorKindPicker: View {
    @Binding var selection: CursorKind

    var body: some View {
        if #available(macOS 27.0, *) {
            picker
                .pickerStyle(.tabs)
                .controlSize(.extraLarge)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        } else {
            picker
                .pickerStyle(.segmented)
                .controlSize(.large)
        }
    }

    private var picker: some View {
        Picker("Cursor type", selection: $selection) {
            ForEach(CursorKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }
        .labelsHidden()
    }
}
