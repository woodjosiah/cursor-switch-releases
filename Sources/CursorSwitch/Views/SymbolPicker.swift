import SwiftUI

struct SymbolPicker: View {
    @Binding var symbolName: String
    @State private var search = ""
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    private var choices: [SymbolChoice] {
        SymbolChoice.choices.filter {
            $0.matches(search) && NSImage(systemSymbolName: $0.name, accessibilityDescription: nil) != nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search symbols", text: $search, prompt: Text("Search hearts, arrows, hands…"))
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            if choices.isEmpty {
                Text("No matching symbols. Try a word like “heart” or “hand”.")
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(choices) { choice in
                            Button { symbolName = choice.name } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: choice.name).font(.title2)
                                    Text(choice.title).font(.caption).lineLimit(1).minimumScaleFactor(0.8)
                                }
                                .frame(maxWidth: .infinity, minHeight: 58)
                                .foregroundStyle(.primary)
                                .background(symbolName == choice.name ? Color.orange.opacity(0.12) : .clear,
                                            in: .rect(cornerRadius: 8))
                                .overlay {
                                    if symbolName == choice.name {
                                        RoundedRectangle(cornerRadius: 8).strokeBorder(.orange, lineWidth: 1.5)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(choice.title)
                            .accessibilityAddTraits(symbolName == choice.name ? .isSelected : [])
                        }
                    }
                    .padding(2)
                }
                .frame(maxHeight: 200)
            }
            DisclosureGroup("Use a symbol name…") {
                TextField("SF Symbol name", text: $symbolName, prompt: Text("star.fill"))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .padding(.top, 4)
            }
            .font(.callout)
        }
    }
}
