// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AliyunOneClickLogin",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "AliyunOneClickLogin", targets: ["AliyunOneClickLogin"])
    ],
    targets: [
        .binaryTarget(
            name: "ATAuthSDK",
            path: "xcframeworks/ATAuthSDK.xcframework"
        ),
        .binaryTarget(
            name: "YTXOperators",
            path: "xcframeworks/YTXOperators.xcframework"
        ),
        .binaryTarget(
            name: "YTXMonitor",
            path: "xcframeworks/YTXMonitor.xcframework"
        ),
        .target(
            name: "AliyunOneClickLogin",
            dependencies: [
                .target(name: "ATAuthSDK"),
                .target(name: "YTXOperators"),
                .target(name: "YTXMonitor")
            ]
        )
    ]
)
