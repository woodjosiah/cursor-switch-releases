// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CursorSwitch",
    platforms: [.macOS(.v15)],
    products: [.executable(name: "CursorSwitch", targets: ["CursorSwitch"])],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1")
    ],
    targets: [
        .executableTarget(
            name: "CursorSwitch",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")],
            linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]
        ),
        .testTarget(name: "CursorSwitchTests", dependencies: ["CursorSwitch"])
    ]
)
