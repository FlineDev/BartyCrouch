// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BartyCrouch",
    products: [
        .executable(name: "bartycrouch", targets: ["BartyCrouch"]),
        .library(name: "BartyCrouchKit", targets: ["BartyCrouchKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/kiliankoe/CLISpinner.git", .upToNextMinor(from: "0.3.5")),
        .package(url: "https://github.com/Flinesoft/HandySwift.git", .upToNextMajor(from: "2.6.0")),
        .package(url: "https://github.com/JamitLabs/MungoHealer.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "3.1.4")),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/jdfergason/swift-toml.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "BartyCrouch",
            dependencies: ["BartyCrouchKit"],
            path: "Sources/BartyCrouch"
        ),
        .target(
            name: "BartyCrouchKit",
            dependencies: [
                "BartyCrouchTranslator",
                "CLISpinner",
                "HandySwift",
                "MungoHealer",
                "Rainbow",
                "SwiftCLI",
                "Toml"
            ],
            path: "Sources/BartyCrouchKit"
        ),
        .testTarget(
            name: "BartyCrouchKitTests",
            dependencies: ["BartyCrouchKit", "Toml"],
            path: "Tests/BartyCrouchKitTests"
        ),
        .target(
            name: "BartyCrouchTranslator",
            dependencies: ["HandySwift", "MungoHealer"],
            path: "Sources/BartyCrouchTranslator"
        ),
        .testTarget(
            name: "BartyCrouchTranslatorTests",
            dependencies: ["BartyCrouchTranslator"],
            path: "Tests/BartyCrouchTranslatorTests"
        )
    ],
    swiftLanguageVersions: [.v4_2]
)
