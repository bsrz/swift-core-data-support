// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-core-data-support",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "CoreDataSupport",
            targets: ["CoreDataSupport"]
        ),
    ],
    targets: [
        .target(
            name: "CoreDataSupport"
        ),
        .testTarget(
            name: "CoreDataSupportTests",
            dependencies: ["CoreDataSupport"],
            resources: [.process("Resources")]
        ),
    ]
)
