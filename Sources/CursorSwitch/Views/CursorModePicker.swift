import SwiftUI

struct CursorModePicker: View {
    var store: CursorStore

    var body: some View {
        HStack(spacing: 12) {
            modeButton("Default", symbol: "cursorarrow", selected: !store.isCustom) { store.selectDefault() }
            modeButton("Custom", symbol: "cursorarrow.rays", selected: store.isCustom) { store.selectCustom() }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cursor mode")
    }

    private func modeButton(_ title: String, symbol: String, selected: Bool,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: symbol).foregroundStyle(.primary)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? Color.orange : Color.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
