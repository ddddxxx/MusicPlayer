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
