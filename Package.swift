// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "wa",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3"),
    ],
    targets: [
        .executableTarget(
            name: "wa",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)