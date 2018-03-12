// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "HandySwift",
    products: [
        .library(
            name: "HandySwift",
            targets: ["HandySwift"]
        )
    ],
    targets: [
        .target(
            name: "HandySwift",
            path: "Sources",
            exclude: [
                "Sources/Supporting Files"
            ]
        )
    ],
    swiftLanguageVersions: [4]
)
