import BartyCrouchUtility
import Foundation
import MungoHealer
import Toml

public struct LintOptions {
  public let paths: [String]
  public let subpathsToIgnore: [String]
  public let duplicateKeys: Bool
  public let emptyValues: Bool
}

extension LintOptions: TomlCodable {
  static func make(toml: Toml) throws -> LintOptions {
    let lint: String = "lint"

    return LintOptions(
      paths: toml.filePaths(lint, singularKey: "path", pluralKey: "paths"),
      subpathsToIgnore: toml.array(lint, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore,
      duplicateKeys: toml.bool(lint, "duplicateKeys") ?? true,
      emptyValues: toml.bool(lint, "emptyValues") ?? true
    )
  }

  func tomlContents() -> String {
    var lines: [String] = ["[lint]"]

    lines.append("paths = \(paths)")
    lines.append("subpathsToIgnore = \(subpathsToIgnore)")
    lines.append("duplicateKeys = \(duplicateKeys)")
    lines.append("emptyValues = \(emptyValues)")

    return lines.joined(separator: "\n")
  }
}
