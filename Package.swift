// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MusicPlayer",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10),
    ],
    products: [
        .library(name: "MusicPlayer", targets: ["MusicPlayer"]),
        .library(name: "LXMusicPlayer", targets: ["LXMusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/cx-org/CXExtensions", .upToNextMinor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: [
                .target(name: "LXMusicPlayer", condition: .when(platforms: [.macOS])),
                .target(name: "MediaRemotePrivate", condition: .when(platforms: [.macOS, .iOS])),
                "CXExtensions",
                .product(name: "CXShim", package: "CombineX"),
            ]),
        .target(
            name: "LXMusicPlayer",
            cSettings: [
                .headerSearchPath("private"),
                .headerSearchPath("BridgingHeader"),
        ]),
        .target(
            name: "MediaRemotePrivate"),
    ]
)

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

extension ProcessInfo {

    var combineImplementation: CombineImplementation {
        return environment["CX_COMBINE_IMPLEMENTATION"].flatMap(CombineImplementation.init) ?? .default
    }
    
    var enableSpotifyiOS: Bool {
        return environment["LX_ENABLE_SPOTIFYIOS"] != nil
    }
}

import Foundation

let info = ProcessInfo.processInfo

if info.combineImplementation == .combine {
    package.platforms = [.macOS("10.15"), .iOS("13.0")]
}

// This breaks macOS build
// error: While building for macOS, no library for this platform was found in 'SpotifyiOS.xcframework'.
if info.enableSpotifyiOS {
    package.dependencies += [
        .package(url: "https://github.com/ddddxxx/SpotifyiOSWrapper", from: "1.2.2"),
    ]
    package.targets.first { $0.name == "MusicPlayer" }!.dependencies += [
        .product(name: "SpotifyiOSWrapper", package: "SpotifyiOSWrapper", condition: .when(platforms: [.iOS]))
    ]
}
