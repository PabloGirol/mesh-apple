// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Meshtastic",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "Meshtastic", targets: ["Meshtastic"])
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/SwiftDraw", "0.22.0"..<"1.0.0"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-DFU-Library", "4.16.0"..<"5.0.0"),
        .package(url: "https://github.com/emqx/CocoaMQTT", "1.3.0-rc.2"..<"2.0.0"),
        .package(url: "https://github.com/DataDog/dd-sdk-ios.git", "3.3.0"..<"4.0.0"),
        .package(url: "https://github.com/swiftlang/swift-markdown", "0.5.0"..<"1.0.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", "1.39.0"..<"2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift", "5.0.0"..<"6.0.0"),
        .package(url: "https://github.com/Outdooractive/gis-tools", "1.0.0"..<"2.0.0"),
        .package(url: "https://github.com/apple/swift-cmark.git", "0.9.0"..<"1.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", "0.9.0"..<"1.0.0"),
        .package(path: "MeshtasticProtobufs"),
        .package(path: "Packages/mvt-tools"),
    ],
    targets: [
        .target(
            name: "Meshtastic",
            dependencies: [
                "SwiftDraw",
                "NordicDFU",
                "CocoaMQTT",
                "DatadogCore",
                "DatadogCrashReporting",
                "DatadogLogs",
                "DatadogRUM",
                "DatadogTrace",
                "Markdown",
                "SwiftProtobuf",
                "Logging",
                "ArgumentParser",
                "Gzip",
                "GISTools",
                "CMark",
                "ZIPFoundation",
                "MeshtasticProtobufs",
                "MVTTools",
            ],
            path: "Meshtastic"
        )
    ]
)
