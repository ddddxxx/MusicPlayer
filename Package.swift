// swift-tools-version:5.1

import PackageDescription
import Foundation

let useCombineX = ProcessInfo.processInfo.environment["SWIFT_PACKAGE_USE_COMBINEX"] != nil
//let useCombineX = true

let supportedPlatform: [SupportedPlatform]

if useCombineX {
    supportedPlatform = [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ]
} else {
    supportedPlatform = [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("6.0"),
    ]
}

let package = Package(
    name: "MusicPlayer",
    platforms: supportedPlatform,
    products: [
        .library(
            name: "MusicPlayer",
            targets: ["MusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CXCompatible", .branch("master")),
    ],
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: [
                .product(name: "CXShim")
            ],
            swiftSettings: useCombineX ? [.define("USE_COMBINEX")] : nil
        ),
    ]
)
