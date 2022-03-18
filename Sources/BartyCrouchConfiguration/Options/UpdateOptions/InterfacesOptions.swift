import BartyCrouchUtility
import Foundation
import Toml

public struct InterfacesOptions {
  public let paths: [String]
  public let subpathsToIgnore: [String]
  public let defaultToBase: Bool
  public let ignoreEmptyStrings: Bool
  public let unstripped: Bool
  public let ignoreKeys: [String]
}

extension InterfacesOptions: TomlCodable {
  static func make(toml: Toml) throws -> InterfacesOptions {
    let update: String = "update"
    let interfaces: String = "interfaces"

    return InterfacesOptions(
      paths: toml.filePaths(update, interfaces, singularKey: "path", pluralKey: "paths"),
      subpathsToIgnore: toml.array(update, interfaces, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore,
      defaultToBase: toml.bool(update, interfaces, "defaultToBase") ?? false,
      ignoreEmptyStrings: toml.bool(update, interfaces, "ignoreEmptyStrings") ?? false,
      unstripped: toml.bool(update, interfaces, "unstripped") ?? false,
      ignoreKeys: toml.array(update, interfaces, "ignoreKeys") ?? Constants.defaultIgnoreKeys
    )
  }

  func tomlContents() -> String {
    var lines: [String] = ["[update.interfaces]"]

    lines.append("paths = \(paths)")
    lines.append("subpathsToIgnore = \(subpathsToIgnore)")
    lines.append("defaultToBase = \(defaultToBase)")
    lines.append("ignoreEmptyStrings = \(ignoreEmptyStrings)")
    lines.append("unstripped = \(unstripped)")
    lines.append("ignoreKeys = \(ignoreKeys)")

    return lines.joined(separator: "\n")
  }
}
