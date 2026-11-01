import Foundation

enum ClickIndicatorStyle: String, Codable, CaseIterable, Identifiable {
    case pulseRing
    case ripple

    var id: Self { self }
    var title: String {
        switch self {
        case .pulseRing: "Pulse ring"
        case .ripple: "Ripple"
        }
    }
}
