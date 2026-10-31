import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Development"
    }
    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable().scaledToFit().frame(width: 104, height: 104)
                .accessibilityLabel("Cursor Switch logo")
            VStack(spacing: 6) {
                Text("Cursor Switch").font(.title2).bold()
                Text("Version \(version) (\(build))")
                    .font(.callout).foregroundStyle(.secondary).textSelection(.enabled)
            }
            Text("A little personality for your pointer.")
                .foregroundStyle(.secondary)
            Divider()
            VStack(spacing: 8) {
                Text("Created by Josiah Wood")
                Link("josiah.io", destination: URL(string: "https://josiah.io")!)
            }
            VStack(spacing: 4) {
                Text("Automatic updates powered by")
                    .foregroundStyle(.secondary)
                Link("Sparkle", destination: URL(string: "https://sparkle-project.org")!)
            }
            .font(.callout)
        }
        .multilineTextAlignment(.center)
        .padding(28)
        .frame(width: 360)
    }
}
