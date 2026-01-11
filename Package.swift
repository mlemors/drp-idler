// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiscordRPC-Idler",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "DiscordRPC-Idler",
            targets: ["DiscordRPCIdler"]
        ),
        .library(
            name: "DiscordRPCIdlerLib",
            type: .dynamic,
            targets: ["DiscordRPCIdlerLib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0"),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.0.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DiscordRPCIdlerLib",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
            ],
            path: "Sources",
            exclude: ["App/main.swift"]
        ),
        .executableTarget(
            name: "DiscordRPCIdler",
            dependencies: ["DiscordRPCIdlerLib"],
            path: "Sources/App",
            sources: ["main.swift"]
        )
    ]
)
