// swift-tools-version:5.4
import PackageDescription

let package = Package(
  name: "BartyCrouch",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "bartycrouch", targets: ["BartyCrouch"]),
    .library(name: "BartyCrouchKit", targets: ["BartyCrouchKit"]),
    .library(name: "BartyCrouchTranslator", targets: ["BartyCrouchTranslator"]),
  ],
  dependencies: [
    .package(name: "HandySwift", url: "https://github.com/Flinesoft/HandySwift.git", from: "3.2.0"),
    .package(name: "Microya", url: "https://github.com/Flinesoft/Microya.git", .branch("support/without-combine")),
    .package(name: "MungoHealer", url: "https://github.com/Flinesoft/MungoHealer.git", from: "0.3.4"),
    .package(name: "Rainbow", url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),
    .package(name: "SwiftCLI", url: "https://github.com/jakeheis/SwiftCLI.git", from: "6.0.3"),
    .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", from: "0.50500.0"),
    .package(name: "SwiftyXML", url: "https://github.com/chenyunguiMilook/SwiftyXML.git", from: "3.1.0"),
    .package(name: "Toml", url: "https://github.com/jdfergason/swift-toml.git", .branch("master")),
  ],
  targets: [
    .executableTarget(
      name: "BartyCrouch",
      dependencies: ["BartyCrouchKit"]
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
        "SwiftyXML",
        "Toml",
      ]
    ),
    .testTarget(
      name: "BartyCrouchKitTests",
      dependencies: ["BartyCrouchKit", "Toml"]
    ),
    .target(
      name: "BartyCrouchTranslator",
      dependencies: ["HandySwift", "Microya", "MungoHealer"]
    ),
    .testTarget(
      name: "BartyCrouchTranslatorTests",
      dependencies: ["BartyCrouchTranslator"]
    )
  ]
)
