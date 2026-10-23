// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "WhiteNoise",
    platforms: [.macOS(.v27)],
    targets: [
        .executableTarget(
            name: "WhiteNoise",
            path: "Sources/WhiteNoise",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
