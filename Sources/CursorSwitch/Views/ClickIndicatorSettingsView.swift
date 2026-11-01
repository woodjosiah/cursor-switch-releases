import SwiftUI

struct ClickIndicatorSettingsView: View {
    @Bindable var store: ClickIndicatorStore
    @State private var color = Color.clear
    @State private var rightClickColor = Color.clear

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Show clicks", isOn: $store.settings.isEnabled)
                .toggleStyle(.switch)
            if store.settings.isEnabled {
                Picker("Click style", selection: $store.settings.style) {
                    ForEach(ClickIndicatorStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                LabeledContent("Effect size") {
                    Slider(value: $store.settings.size, in: ClickIndicatorSettings.sizeRange)
                        .accessibilityLabel("Click effect size")
                        .accessibilityValue("\(Int(store.settings.size)) points")
                    Text("\(Int(store.settings.size)) pt")
                        .monospacedDigit().frame(width: 46, alignment: .trailing)
                }
                ColorPicker("Effect color", selection: $color, supportsOpacity: false)
                Toggle("Distinguish right-clicks", isOn: $store.settings.usesRightClickColor)
                if store.settings.usesRightClickColor {
                    ColorPicker("Right-click color", selection: $rightClickColor, supportsOpacity: false)
                    Text("Right-clicks use a dashed ring.")
                        .font(.callout).foregroundStyle(.secondary)
                }
            }
            if let message = store.errorMessage {
                Text(message).font(.callout).foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear { syncColors() }
        .onChange(of: store.settings.color) { syncColors() }
        .onChange(of: store.settings.rightClickColor) { syncColors() }
        .onChange(of: color) { store.settings.color = CursorColor(color) }
        .onChange(of: rightClickColor) { store.settings.rightClickColor = CursorColor(rightClickColor) }
    }

    private func syncColors() {
        if CursorColor(color) != store.settings.color { color = store.settings.color.color }
        if CursorColor(rightClickColor) != store.settings.rightClickColor {
            rightClickColor = store.settings.rightClickColor.color
        }
    }
}
