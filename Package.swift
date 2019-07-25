// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "JYMoleculeTool-Swift",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .executable(name: "JYMT-StructureFinder", targets: ["JYMT-StructureFinder"]),
        .executable(name: "JYMT-ABCTool", targets: ["JYMT-ABCTool"]),
        .executable(name: "JYMT-ABCCalculator", targets: ["JYMT-ABCCalculator"])
    ],
    dependencies: [
        .package(path: "Libraries/JYMTKit")
    ],
    targets: [
        .target(
            name: "JYMT-StructureFinder",
            dependencies: ["JYMTBasicKit"]),
        .target(
            name: "JYMT-ABCTool",
            dependencies: ["JYMTBasicKit"]
        ),
        .target(
            name: "JYMT-ABCCalculator",
            dependencies: ["JYMTBasicKit", "JYMTAdvancedKit"]
        )
    ]
)