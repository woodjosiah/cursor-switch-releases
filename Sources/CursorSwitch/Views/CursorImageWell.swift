import SwiftUI
import UniformTypeIdentifiers

struct CursorImageWell: View {
    @Binding var profile: CursorProfile
    @State private var isTargeted = false
    @State private var showsImporter = false
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button { showsImporter = true } label: {
                HStack(spacing: 12) {
                    if let data = profile.imagePNG, let image = NSImage(data: data) {
                        Image(nsImage: image).resizable().scaledToFit().frame(width: 44, height: 44)
                    } else {
                        Image(systemName: "photo.badge.plus").font(.title2).frame(width: 44, height: 44)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.imageName ?? "Drop your image here").lineLimit(1)
                        Text(isImporting ? "Importing…" : "or click to choose · transparency supported")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(isTargeted ? Color.orange.opacity(0.12) : Color.primary.opacity(0.03))
                .clipShape(.rect(cornerRadius: 8))
                .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(isTargeted ? Color.orange : Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4])) }
            }
            .buttonStyle(.plain)
            .disabled(isImporting)
            .accessibilityLabel(profile.imageName == nil ? "Choose or drop a cursor image" : "Replace cursor image: \(profile.imageName ?? "")")
            .dropDestination(for: URL.self) { urls, _ in
                guard !isImporting, urls.count == 1, let url = urls.first, url.isFileURL else { return false }
                importImage(url)
                return true
            } isTargeted: { isTargeted = $0 }
            .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.png, .jpeg, .heic, .tiff, .gif, .bmp]) { result in
                switch result {
                case .success(let url): importImage(url)
                case .failure(let error): importError = error.localizedDescription
                }
            }
            if let importError { Text(importError).font(.callout).foregroundStyle(.red) }
            if profile.imagePNG != nil {
                Button("Remove Image") {
                    profile.imagePNG = nil
                    profile.imageName = nil
                    importError = nil
                }
                .font(.callout)
            }
        }
    }

    private func importImage(_ url: URL) {
        isImporting = true
        importError = nil
        Task {
            do {
                let imported = try await Task.detached(priority: .userInitiated) { try CursorImageImport.load(url) }.value
                profile.imagePNG = imported.png
                profile.imageName = imported.name
            } catch {
                importError = error.localizedDescription
            }
            isImporting = false
        }
    }
}
