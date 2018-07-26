// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BartyCrouch",
    products: [
        .executable(name: "bartycrouch", targets: ["BartyCrouch CLI"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BartyCrouch CLI",
            dependencies: [],
            path: ".",
            sources: [
                "BartyCrouch CLI/",
                "Sources/Code",
                "Carthage/CommandLine",
                "Carthage/HandySwift",
                "Carthage/Polyglot"
            ]
        )
    ],
    swiftLanguageVersions: [4]
)
