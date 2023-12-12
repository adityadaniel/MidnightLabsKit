// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MidnightLabsKit",
    platforms: [
      .iOS(.v14),
    ],
    products: [
        .library(
            name: "MidnightLabsKit",
            targets: ["MidnightLabsKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/RevenueCat/purchases-ios", .upToNextMajor(from: "4.31.2"))
    ],
    targets: [
        .target(
            name: "MidnightLabsKit",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "MidnightLabsKitTests",
            dependencies: ["MidnightLabsKit"]
        ),
    ]
)
