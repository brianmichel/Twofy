// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
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
                "BrowserSupportService",
                "ServiceBrokerService",
                "DistributedNotificationIPC"
            ]
        ),
        .library(name: "ExtensionMessageBus", targets: ["ExtensionMessageBus"]),
        .library(name: "MessageDatabaseListener", targets: ["MessageDatabaseListener"]),
        .library(name: "Utilities", targets: ["Utilities"]),
        .library(name: "ManifestInstallerService", targets: ["ManifestInstallerService"]),
        .library(name: "BrowserSupportService", targets: ["BrowserSupportService"]),
        .library(name: "ServiceBrokerService", targets: ["ServiceBrokerService"]),
        .library(name: "XPCSupport", targets: ["XPCSupport"]),
        .library(name: "DistributedNotificationIPC", targets: ["DistributedNotificationIPC"]),
        .library(name: "MessageEncryption", targets: ["MessageEncryption"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.27.0"),
        .package(url: "https://github.com/jedisct1/swift-sodium.git", from: "0.9.1"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "MessageDatabaseListener",
                "MessageEncryption"
            ]),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]),
        .target(
            name: "BrowserSupportService",
            dependencies: [
                "ExtensionMessageBus",
                "Utilities",
                "XPCSupport",
            ]
        ),
        .target(
            name: "ExtensionMessageBus",
            dependencies: ["Utilities"]),
        .testTarget(name: "ExtensionMessageBusTests", dependencies: ["ExtensionMessageBus"]),
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
        .target(name: "ServiceBrokerService"),
        .target(name: "XPCSupport"),
        .target(
            name: "DistributedNotificationIPC",
            dependencies: [
                "MessageEncryption"
            ]),
        .target(
            name: "MessageEncryption",
            dependencies: [
                .product(name: "KeychainAccess", package: "keychainaccess"),
                .product(name: "Sodium", package: "swift-sodium"),
            ]
        )
    ]
)
