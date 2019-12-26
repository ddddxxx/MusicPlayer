// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MusicPlayer",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(name: "MusicPlayer", targets: ["MusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .target(name: "MusicPlayer", dependencies: ["CXShim"]),
    ]
)

#if os(macOS)

package.targets += [
    .target(
        name: "LXMusicPlayer",
        cSettings: [
            .headerSearchPath("private"),
            .headerSearchPath("BridgingHeader"),
    ]),
]
package.targets.first { $0.name == "MusicPlayer" }!.dependencies += ["LXMusicPlayer"]
package.products += [
    .library(name: "LXMusicPlayer", targets: ["LXMusicPlayer"]),
]

#endif
