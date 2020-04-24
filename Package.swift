// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BartyCrouch",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(name: "bartycrouch", targets: ["BartyCrouch"]),
        .library(name: "BartyCrouchKit", targets: ["BartyCrouchKit"]),
        .library(name: "BartyCrouchTranslator", targets: ["BartyCrouchTranslator"]),
    ],
    dependencies: [
        .package(name: "HandySwift", url: "https://github.com/Flinesoft/HandySwift.git", from: "3.2.0"),
        .package(name: "Microya", url: "https://github.com/Flinesoft/Microya.git", from: "0.1.1"),
        .package(name: "MungoHealer", url: "https://github.com/JamitLabs/MungoHealer.git", from: "0.3.2"),
        .package(name: "Rainbow", url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),
        .package(name: "SwiftCLI", url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.1"),
        .package(name: "Toml", url: "https://github.com/jdfergason/swift-toml.git", .branch("master")),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50200.0")),
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
                "HandySwift",
                "MungoHealer",
                "Rainbow",
                "SwiftCLI",
                "SwiftSyntax",
                "Toml",
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
            dependencies: ["HandySwift", "Microya", "MungoHealer"],
            path: "Sources/BartyCrouchTranslator"
        ),
        .testTarget(
            name: "BartyCrouchTranslatorTests",
            dependencies: ["BartyCrouchTranslator"],
            path: "Tests/BartyCrouchTranslatorTests"
        )
    ]
)
