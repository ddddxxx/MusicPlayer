// swift-tools-version:5.1

import PackageDescription

//import Foundation
//let useCombineX = ProcessInfo.processInfo.environment["USE_COMBINEX"] != nil
let useCombineX = true

let supportedPlatform: [SupportedPlatform]
let combinePackageDependencies: [Package.Dependency]
let combineTargetDependencies: [PackageDescription.Target.Dependency]
let combineSwiftSetting: [SwiftSetting]?

if useCombineX {
    supportedPlatform = [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ]
    combinePackageDependencies = [
        .package(url: "https://github.com/cx-org/CXFoundation", .branch("master")),
    ]
    combineTargetDependencies = [
        .product(name: "CXFoundation"),
    ]
    combineSwiftSetting = [
        .define("USE_COMBINEX")
    ]
} else {
    supportedPlatform = [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("6.0"),
    ]
    combinePackageDependencies = [
        .package(url: "https://github.com/cx-org/CXCompatible", .branch("master")),
    ]
    combineTargetDependencies = [
        .product(name: "CXCompatible"),
    ]
    combineSwiftSetting = nil
}

let package = Package(
    name: "MusicPlayer",
    platforms: supportedPlatform,
    products: [
        .library(
            name: "MusicPlayer",
            targets: ["MusicPlayer"]),
    ],
    dependencies: [] + combinePackageDependencies,
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: [] + combineTargetDependencies,
            swiftSettings: combineSwiftSetting
        ),
    ]
)
