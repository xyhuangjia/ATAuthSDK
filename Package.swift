// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ATAuthSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "ATAuthSDK", targets: ["ATAuthSDK"])
    ],
    targets: [
        .binaryTarget(name: "ATAuthSDKCore", path: "xcframeworks/ATAuthSDK.xcframework"),
        .binaryTarget(name: "YTXOperators", path: "xcframeworks/YTXOperators.xcframework"),
        .binaryTarget(name: "YTXMonitor", path: "xcframeworks/YTXMonitor.xcframework"),
        .target(name: "ATAuthSDK", dependencies: [
            .target(name: "ATAuthSDKCore"),
            .target(name: "YTXOperators"),
            .target(name: "YTXMonitor")
        ])
    ]
)
