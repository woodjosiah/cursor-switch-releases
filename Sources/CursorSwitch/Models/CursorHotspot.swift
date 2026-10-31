import Foundation

enum CursorHotspot: String, Codable, CaseIterable, Identifiable {
    case automatic, topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight
    var id: Self { self }
    var title: String {
        switch self {
        case .automatic: "Top visible pixel"
        case .topLeft: "Top left"
        case .top: "Top"
        case .topRight: "Top right"
        case .left: "Left"
        case .center: "Center"
        case .right: "Right"
        case .bottomLeft: "Bottom left"
        case .bottom: "Bottom"
        case .bottomRight: "Bottom right"
        }
    }

    var normalizedPoint: CGPoint {
        switch self {
        case .automatic, .center: CGPoint(x: 0.5, y: 0.5)
        case .topLeft: .zero
        case .top: CGPoint(x: 0.5, y: 0)
        case .topRight: CGPoint(x: 1, y: 0)
        case .left: CGPoint(x: 0, y: 0.5)
        case .right: CGPoint(x: 1, y: 0.5)
        case .bottomLeft: CGPoint(x: 0, y: 1)
        case .bottom: CGPoint(x: 0.5, y: 1)
        case .bottomRight: CGPoint(x: 1, y: 1)
        }
    }
}
