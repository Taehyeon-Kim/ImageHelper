// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageCache",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(
            name: "ImageCache",
            targets: ["ImageCache"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ImageCache"),
        .testTarget(
            name: "ImageCacheTests",
            dependencies: ["ImageCache"]),
    ]
)
