import BartyCrouchUtility
import Foundation
import Toml

public struct CodeOptions {
  public let codePaths: [String]
  public let subpathsToIgnore: [String]
  public let localizablePaths: [String]
  public let defaultToKeys: Bool
  public let additive: Bool
  public let customFunction: String?
  public let customLocalizableName: String?
  public let unstripped: Bool
  public let plistArguments: Bool
  public let ignoreKeys: [String]
}

extension CodeOptions: TomlCodable {
  static func make(toml: Toml) throws -> CodeOptions {
    let update: String = "update"
    let code: String = "code"

    return CodeOptions(
      codePaths: toml.filePaths(update, code, singularKey: "codePath", pluralKey: "codePaths"),
      subpathsToIgnore: toml.array(update, code, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore,
      localizablePaths: toml.filePaths(update, code, singularKey: "localizablePath", pluralKey: "localizablePaths"),
      defaultToKeys: toml.bool(update, code, "defaultToKeys") ?? false,
      additive: toml.bool(update, code, "additive") ?? true,
      customFunction: toml.string(update, code, "customFunction"),
      customLocalizableName: toml.string(update, code, "customLocalizableName"),
      unstripped: toml.bool(update, code, "unstripped") ?? false,
      plistArguments: toml.bool(update, code, "plistArguments") ?? true,
      ignoreKeys: toml.array(update, code, "ignoreKeys") ?? Constants.defaultIgnoreKeys
    )
  }

  func tomlContents() -> String {
    var lines: [String] = ["[update.code]"]

    lines.append("codePaths = \(codePaths)")
    lines.append("subpathsToIgnore = \(subpathsToIgnore)")
    lines.append("localizablePaths = \(localizablePaths)")
    lines.append("defaultToKeys = \(defaultToKeys)")
    lines.append("additive = \(additive)")

    if let customFunction = customFunction {
      lines.append("customFunction = \"\(customFunction)\"")
    }

    if let customLocalizableName = customLocalizableName {
      lines.append("customLocalizableName = \"\(customLocalizableName)\"")
    }

    lines.append("unstripped = \(unstripped)")
    lines.append("plistArguments = \(plistArguments)")
    lines.append("ignoreKeys = \(Constants.defaultIgnoreKeys)")

    return lines.joined(separator: "\n")
  }
}
