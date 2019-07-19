// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "JYMTKit",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "JYMTBasicKit", targets: ["JYMTBasicKit"]),
        .library(name: "JYMTAdvancedKit", targets: ["JYMTAdvancedKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "JYMTBasicKit",
            dependencies: []),
        .target(
            name: "JYMTAdvancedKit",
            dependencies: ["JYMTBasicKit", "PythonKit"])
    ]
)
