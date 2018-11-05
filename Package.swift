// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BartyCrouch",
    products: [
        .executable(name: "bartycrouch", targets: ["BartyCrouch"]),
        .library(name: "BartyCrouchKit", targets: ["BartyCrouchKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/jatoben/CommandLine.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Flinesoft/HandySwift.git", .upToNextMajor(from: "2.6.0")),
        .package(url: "https://github.com/Dschee/Polyglot.git", .branch("master")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "3.1.4")),
    ],
    targets: [
        .target(
            name: "BartyCrouch",
            dependencies: ["BartyCrouchKit"],
            path: "Sources/BartyCrouch",
            exclude: ["Sources/SupportingFiles"]
        ),
        .target(
            name: "BartyCrouchKit",
            dependencies: ["CommandLine", "HandySwift", "Polyglot", "Rainbow"],
            path: "Sources/BartyCrouchKit",
            exclude: ["Sources/SupportingFiles"]
        ),
        .testTarget(
            name: "BartyCrouchKitTests",
            dependencies: ["BartyCrouchKit"],
            path: "Tests/BartyCrouchKitTests",
            exclude: ["Tests/SupportingFiles"]
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
