import Foundation
import ImageIO
import UniformTypeIdentifiers

enum CursorImageImport {
    struct ImportedImage: Sendable {
        let png: Data
        let name: String
    }

    static func load(_ url: URL) throws -> ImportedImage {
        guard url.isFileURL else { throw ImportFailure.notAFile }
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true else { throw ImportFailure.notAFile }
        guard let size = values.fileSize, size <= 20 * 1_024 * 1_024 else { throw ImportFailure.tooLarge }
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        return ImportedImage(png: try normalize(data), name: url.lastPathComponent)
    }

    /// Decode a bounded thumbnail, preserving alpha and orientation, then keep a
    /// local PNG copy so the original file can be moved or deleted safely.
    static func normalize(_ data: Data) throws -> Data {
        guard data.count <= 20 * 1_024 * 1_024 else { throw ImportFailure.tooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 512,
                kCGImageSourceShouldCacheImmediately: true
              ] as CFDictionary) else { throw ImportFailure.unreadable }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil) else {
            throw ImportFailure.unreadable
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ImportFailure.unreadable }
        return output as Data
    }
}

enum ImportFailure: LocalizedError {
    case notAFile, tooLarge, unreadable
    var errorDescription: String? {
        switch self {
        case .notAFile: "Choose an image file from your Mac."
        case .tooLarge: "Choose an image smaller than 20 MB."
        case .unreadable: "This image couldn’t be opened. Try a PNG, JPEG, HEIC, TIFF, or GIF."
        }
    }
}
