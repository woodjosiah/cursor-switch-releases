import Foundation

enum CursorKind: String, Codable, CaseIterable, Identifiable {
    case shape, symbol, emoji, image
    var id: Self { self }
    var title: String {
        switch self {
        case .shape: "Shape"
        case .symbol: "SF Symbol"
        case .emoji: "Emoji"
        case .image: "Image"
        }
    }
}
