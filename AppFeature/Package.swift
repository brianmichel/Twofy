// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: [
                "AppFeature",
                "ExtensionMessageBus",
                "MessageDatabaseListener",
                "Utilities",
                "ManifestInstallerService",
            ]
        ),
        .library(name: "ExtensionMessageBus", targets: ["ExtensionMessageBus"]),
        .library(name: "MessageDatabaseListener", targets: ["MessageDatabaseListener"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "ManifestInstallerService", targets: ["ManifestInstallerService"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.27.0"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "MessageDatabaseListener"
            ]),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]),
        .target(name: "ExtensionMessageBus"),
        .target(
            name: "MessageDatabaseListener",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .target(name: "Utilities"),
        .target(
            name: "ManifestInstallerService",
            dependencies: [
                "Utilities",
                "XPCSupport",
            ]
        ),
        .target(name: "XPCSupport")
    ]
)
