// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "JYMTKit",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "JYMTBasicKit", targets: ["JYMTBasicKit"])
    ],
    targets: [
        .target(
            name: "JYMTBasicKit",
            dependencies: [])
    ]
)
