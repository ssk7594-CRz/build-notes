// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NextBuild",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "NextBuild", targets: ["NextBuildApp"])
    ],
    targets: [
        .executableTarget(
            name: "NextBuildApp",
            path: "Sources/NextBuildApp"
        )
    ]
)
