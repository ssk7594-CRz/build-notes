// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BuildNotes",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BuildNotes", targets: ["BuildNotesApp"])
    ],
    targets: [
        .executableTarget(
            name: "BuildNotesApp",
            path: "Sources/BuildNotesApp"
        )
    ]
)
