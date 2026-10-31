import SwiftUI

struct CursorSourceEditor: View {
    @Binding var profile: CursorProfile

    private let symbols = ["cursorarrow", "star.fill", "heart.fill", "bolt.fill", "hand.point.up.fill", "scope", "paperplane.fill", "sparkles"]
    private let emojis = ["✨", "👆", "🌟", "🔥", "🌸", "🐈", "👻", "🦋"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Cursor type", selection: $profile.kind) {
                ForEach(CursorKind.allCases) { kind in Text(kind.title).tag(kind) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

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
                TextField("SF Symbol name", text: $profile.symbolName, prompt: Text("star.fill"))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                HStack {
                    ForEach(symbols, id: \.self) { name in
                        Button { profile.symbolName = name } label: {
                            Image(systemName: name).frame(maxWidth: .infinity, minHeight: 28)
                        }
                        .help(name)
                        .accessibilityLabel(name)
                    }
                }
            case .emoji:
                HStack {
                    TextField("Emoji", text: $profile.emoji, prompt: Text("Paste an emoji"))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    Button("Emoji & Symbols…") { NSApp.orderFrontCharacterPalette(nil) }
                }
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
