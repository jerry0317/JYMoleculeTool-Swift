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
        .executable(name: "JYMT-ABCCalculator", targets: ["JYMT-ABCCalculator"]),
        .executable(name: "JYMT-MISCalculator", targets: ["JYMT-MISCalculator"]),
        .executable(name: "JYMT-MISTool", targets: ["JYMT-MISTool"])
    ],
    dependencies: [
        .package(url: "https://github.com/jerry0317/JYMTKit", .branch("master"))
    ],
    targets: [
        .target(
            name: "JYMT-StructureFinder",
            dependencies: ["JYMTBasicKit", "JYMTAdvancedKit"]),
        .target(
            name: "JYMT-ABCTool",
            dependencies: ["JYMTBasicKit"]
        ),
        .target(
            name: "JYMT-ABCCalculator",
            dependencies: ["JYMTBasicKit", "JYMTAdvancedKit"]
        ),
        .target(
            name: "JYMT-MISCalculator",
            dependencies: ["JYMTBasicKit", "JYMTAdvancedKit"]
        ),
        .target(
            name: "JYMT-MISTool",
            dependencies: ["JYMTBasicKit", "JYMTAdvancedKit"]
        )
    ]
)
