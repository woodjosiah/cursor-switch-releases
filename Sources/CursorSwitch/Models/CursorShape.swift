import Foundation

enum CursorShape: String, Codable, CaseIterable, Identifiable {
    case arrow, circle, crosshair, diamond

    var id: Self { self }
    var title: String { rawValue.capitalized }
}
