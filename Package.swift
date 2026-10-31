// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CursorSwitch",
    platforms: [.macOS(.v15)],
    products: [.executable(name: "CursorSwitch", targets: ["CursorSwitch"])],
    targets: [
        .executableTarget(name: "CursorSwitch"),
        .testTarget(name: "CursorSwitchTests", dependencies: ["CursorSwitch"])
    ]
)
