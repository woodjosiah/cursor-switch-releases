import AppKit

let destination = URL(fileURLWithPath: CommandLine.arguments[1])
let side: CGFloat = 1024
let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { _ in
    NSColor(srgbRed: 1, green: 0.32, blue: 0.20, alpha: 1).setFill()
    NSBezierPath(roundedRect: CGRect(x: 48, y: 48, width: 928, height: 928), xRadius: 208, yRadius: 208).fill()
    let config = NSImage.SymbolConfiguration(pointSize: 620, weight: .medium)
        .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    if let symbol = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        symbol.draw(in: CGRect(x: 214, y: 190, width: 596, height: 644))
    }
    return true
}
guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("Could not render app icon") }
try png.write(to: destination)
