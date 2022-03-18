import Foundation
import MungoHealer
import Toml

public struct Configuration {
  public static let fileName: String = ".bartycrouch.toml"

  public static var configUrl: URL {
    return URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(Configuration.fileName)
  }

  public let updateOptions: UpdateOptions
  public let lintOptions: LintOptions

  public static func load() throws -> Configuration {
    let configUrl = self.configUrl

    guard FileManager.default.fileExists(atPath: configUrl.path) else {
      return try Configuration.make(toml: try Toml(withString: ""))
    }

    let toml: Toml = try Toml(contentsOfFile: configUrl.path)
    return try Configuration.make(toml: toml)
  }
}

extension Configuration: TomlCodable {
  public static func makeDefault() throws -> Configuration {
    return try make(toml: Toml(withString: ""))
  }

  public static func make(toml: Toml) throws -> Configuration {
    let updateOptions = try UpdateOptions.make(toml: toml)
    let lintOptions = try LintOptions.make(toml: toml)

    return Configuration(updateOptions: updateOptions, lintOptions: lintOptions)
  }

  public func tomlContents() -> String {
    let sections: [String] = [
      updateOptions.tomlContents(),
      lintOptions.tomlContents(),
    ]

    return sections.joined(separator: "\n\n") + "\n"
  }
}
