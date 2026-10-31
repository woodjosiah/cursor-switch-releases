import SwiftUI

struct CursorSourceEditor: View {
    @Binding var profile: CursorProfile

    private let emojis = ["✨", "👆", "🌟", "🔥", "🌸", "🐈", "👻", "🦋"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CursorKindPicker(selection: $profile.kind)

            switch profile.kind {
            case .shape:
                HStack {
                    Text("Shape")
                    Spacer()
                    Picker("Shape", selection: $profile.shape) {
                        ForEach(CursorShape.allCases) { shape in Text(shape.title).tag(shape) }
                    }
                    .labelsHidden()
                    .frame(width: 160)
                }
            case .symbol:
                SymbolPicker(symbolName: $profile.symbolName)
            case .emoji:
                SingleEmojiInput(text: $profile.emoji).frame(height: 26)
                Text("Choose one emoji. Picking another replaces it.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    ForEach(emojis, id: \.self) { emoji in
                        Button { profile.emoji = emoji } label: {
                            Text(emoji).font(.title3).frame(maxWidth: .infinity, minHeight: 28)
                        }
                        .accessibilityLabel("Use \(emoji)")
                    }
                }
            case .image:
                CursorImageWell(profile: $profile)
            }
            if let message = CursorArtwork.validationMessage(for: profile) {
                Text(message).font(.callout).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
