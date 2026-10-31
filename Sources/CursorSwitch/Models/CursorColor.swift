import SwiftUI

struct CursorColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double

    static let coral = CursorColor(red: 1, green: 0.32, blue: 0.20)
    static let white = CursorColor(red: 1, green: 1, blue: 1)

    var color: Color { Color(red: red, green: green, blue: blue) }
    var nsColor: NSColor { NSColor(srgbRed: red, green: green, blue: blue, alpha: 1) }

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init(_ color: Color) {
        let rgb = NSColor(color).usingColorSpace(.sRGB) ?? .black
        self.init(red: rgb.redComponent, green: rgb.greenComponent, blue: rgb.blueComponent)
    }

    var sanitized: Self {
        Self(red: channel(red), green: channel(green), blue: channel(blue))
    }

    private func channel(_ value: Double) -> Double {
        value.isFinite ? min(max(value, 0), 1) : 0
    }
}
