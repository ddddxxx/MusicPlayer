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

var LXMusicPlayerTarget: [Target] = []
var LXMusicPlayerDependency: [Target.Dependency] = []

#if os(macOS)

LXMusicPlayerTarget += [
    .target(
        name: "LXMusicPlayer",
        cSettings: [
            .headerSearchPath("private"),
            .headerSearchPath("BridgingHeader"),
        ]),
]
//LXMusicPlayerDependency += [
//    .target(name: "LXMusicPlayer")
//]

#endif

let package = Package(
    name: "MusicPlayer",
    platforms: supportedPlatform,
    products: [
        .library(name: "MusicPlayer", targets: ["MusicPlayer"]),
        .library(name: "LXMusicPlayer", targets: ["LXMusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CXCompatible", .branch("master")),
    ],
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: [
                .product(name: "CXShim")
            ] + LXMusicPlayerDependency,
            swiftSettings: useCombineX ? [.define("USE_COMBINEX")] : nil
        ),
    ] + LXMusicPlayerTarget
)
