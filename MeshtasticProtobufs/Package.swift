// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MeshtasticProtobufs",
    products: [
        .library(
            name: "MeshtasticProtobufs",
            targets: ["MeshtasticProtobufs"]
        ),
    ], 
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", "1.39.0"..<"2.0.0"),
    ],
    targets: [
        .target(
            name: "MeshtasticProtobufs",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ]
        )
    ]
)
