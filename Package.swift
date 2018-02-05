// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BartyCrouch",
    products: [
        .executable(name: "bartycrouch", targets: ["BartyCrouch CLI"]),
        .library(name: "BartyCrouchKit", targets: ["BartyCrouchKit"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BartyCrouchKit",
            dependencies: [
            ],
            path: ".",
            sources: [
                "Sources/Code",
                "Carthage/CommandLine",
                "Carthage/Handyswift",
                "Carthage/Polyglot"
            ]
        ),
        .target(
            name: "BartyCrouch CLI",
            dependencies: [
                "BartyCrouchKit"
            ],
            path: ".",
            sources: [
                "BartyCrouch CLI/"
            ]
        )
    ],
    swiftLanguageVersions: [4]
)
