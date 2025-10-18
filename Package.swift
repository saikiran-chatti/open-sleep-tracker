// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "open-sleep-tracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "open-sleep-tracker",
            targets: ["open-sleep-tracker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/1998code/SwiftGlass.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "open-sleep-tracker",
            dependencies: [
                .product(name: "SwiftGlass", package: "SwiftGlass")
            ]
        ),
        .testTarget(
            name: "open-sleep-trackerTests",
            dependencies: ["open-sleep-tracker"]
        ),
    ]
)