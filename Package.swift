// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MusicPlayer",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10),
    ],
    products: [
        .library(name: "MusicPlayer", targets: ["MusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: ["CXShim"],
            cSettings: [
                .define("OS_MACOS", .when(platforms: [.macOS]))
        ]),
    ]
)

#if canImport(Darwin)

package.targets += [
    .target(
        name: "LXMusicPlayer",
        cSettings: [
            .define("OS_MACOS", .when(platforms: [.macOS])),
            .headerSearchPath("private"),
            .headerSearchPath("BridgingHeader"),
    ]),
    .target(
        name: "MediaRemotePrivate",
        cSettings: [
            .define("OS_MACOS", .when(platforms: [.macOS])),
    ]),
]
package.targets.first { $0.name == "MusicPlayer" }!.dependencies += ["LXMusicPlayer", "MediaRemotePrivate"]
package.products += [
    .library(name: "LXMusicPlayer", targets: ["LXMusicPlayer"]),
]

#endif

enum CombineImplementation {
    
    case combine
    case combineX
    case openCombine
    
    static var `default`: CombineImplementation {
        #if canImport(Combine)
        return .combine
        #else
        return .combineX
        #endif
    }
    
    init?(_ description: String) {
        let desc = description.lowercased().filter { $0.isLetter }
        switch desc {
        case "combine":     self = .combine
        case "combinex":    self = .combineX
        case "opencombine": self = .openCombine
        default:            return nil
        }
    }
}

import Foundation

let env = ProcessInfo.processInfo.environment
let impkey = "CX_COMBINE_IMPLEMENTATION"

var combineImp = env[impkey].flatMap(CombineImplementation.init) ?? .default

if combineImp == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0"), .tvOS("13.0"), .watchOS("6.0")]
}
