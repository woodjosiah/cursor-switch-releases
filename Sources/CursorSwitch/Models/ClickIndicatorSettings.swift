import Foundation

struct ClickIndicatorSettings: Codable, Equatable {
    static let sizeRange: ClosedRange<Double> = 24...120

    var isEnabled = false
    var style: ClickIndicatorStyle = .pulseRing
    var size: Double = 48
    var color: CursorColor = .coral
    var usesRightClickColor = false
    var rightClickColor = CursorColor(red: 0.20, green: 0.55, blue: 1)

    init() {}

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        style = try values.decodeIfPresent(ClickIndicatorStyle.self, forKey: .style) ?? .pulseRing
        size = try values.decodeIfPresent(Double.self, forKey: .size) ?? 48
        color = try values.decodeIfPresent(CursorColor.self, forKey: .color) ?? .coral
        usesRightClickColor = try values.decodeIfPresent(Bool.self, forKey: .usesRightClickColor) ?? false
        rightClickColor = try values.decodeIfPresent(CursorColor.self, forKey: .rightClickColor) ?? rightClickColor
    }

    var sanitized: Self {
        var copy = self
        copy.size = size.isFinite ? min(max(size, Self.sizeRange.lowerBound), Self.sizeRange.upperBound) : 48
        copy.color = color.sanitized
        copy.rightClickColor = rightClickColor.sanitized
        return copy
    }

    func color(isRightClick: Bool) -> CursorColor {
        isRightClick && usesRightClickColor ? rightClickColor : color
    }
}
