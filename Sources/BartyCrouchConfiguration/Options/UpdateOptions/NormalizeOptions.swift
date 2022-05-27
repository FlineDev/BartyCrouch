import BartyCrouchUtility
import Foundation
import Toml

public struct NormalizeOptions {
  public let paths: [String]
  public let subpathsToIgnore: [String]
  public let sourceLocale: String
  public let harmonizeWithSource: Bool
  public let sortByKeys: Bool
  public let separateWithEmptyLine: Bool
}

extension NormalizeOptions: TomlCodable {
  static func make(toml: Toml) throws -> NormalizeOptions {
    let update: String = "update"
    let normalize: String = "normalize"

    return NormalizeOptions(
      paths: toml.filePaths(update, normalize, singularKey: "path", pluralKey: "paths"),
      subpathsToIgnore: toml.array(update, normalize, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore,
      sourceLocale: toml.string(update, normalize, "sourceLocale") ?? "en",
      harmonizeWithSource: toml.bool(update, normalize, "harmonizeWithSource") ?? true,
      sortByKeys: toml.bool(update, normalize, "sortByKeys") ?? true,
      separateWithEmptyLine: toml.bool(update, normalize, "separateWithEmptyLine") ?? true
    )
  }

  func tomlContents() -> String {
    var lines: [String] = ["[update.normalize]"]

    lines.append("paths = \(self.paths)")
    lines.append("subpathsToIgnore = \(self.subpathsToIgnore)")
    lines.append("sourceLocale = \"\(self.sourceLocale)\"")
    lines.append("harmonizeWithSource = \(self.harmonizeWithSource)")
    lines.append("sortByKeys = \(self.sortByKeys)")
    lines.append("separateWithEmptyLine = \(self.separateWithEmptyLine)")

    return lines.joined(separator: "\n")
  }
}
