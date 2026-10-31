import SwiftUI

struct CursorPreview: View {
    let profile: CursorProfile

    var body: some View {
        HStack(spacing: 0) {
            sample(background: Color(white: 0.94), label: "Light", labelColor: .black.opacity(0.55))
            sample(background: Color(white: 0.16), label: "Dark", labelColor: .white.opacity(0.65))
        }
        .frame(height: 136)
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(profile.kind == .shape ? profile.shape.title : profile.kind.title) cursor preview, \(Int(profile.size)) points, on light and dark backgrounds")
    }

    private func sample(background: Color, label: String, labelColor: Color) -> some View {
        ZStack {
            background
            Image(nsImage: CursorArtwork.image(for: profile))
            VStack {
                Spacer()
                Text(label).font(.caption).foregroundStyle(labelColor).padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
