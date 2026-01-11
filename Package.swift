// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "drp-idler",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "drp-idler",
            targets: ["drpIdler"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0"),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.0.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "drpIdler",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
            ],
            path: "Sources"
        )
    ]
)
