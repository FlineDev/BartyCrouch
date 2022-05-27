import BartyCrouchUtility
import Foundation
import MungoHealer
import Toml

public struct TransformOptions {
  public let codePaths: [String]
  public let subpathsToIgnore: [String]
  public let localizablePaths: [String]
  public let transformer: Transformer
  public let supportedLanguageEnumPath: String
  public let typeName: String
  public let translateMethodName: String
  public let customLocalizableName: String?
  public let separateWithEmptyLine: Bool
}

extension TransformOptions: TomlCodable {
  static func make(toml: Toml) throws -> TransformOptions {
    let update: String = "update"
    let transform: String = "transform"

    guard
      let transformer = Transformer(
        rawValue: toml.string(update, transform, "transformer") ?? Transformer.foundation.rawValue
      )
    else {
      throw MungoError(
        source: .invalidUserInput,
        message: "Unknown `transformer` provided in [update.code.transform]. Supported: \(Transformer.allCases)"
      )
    }

    return TransformOptions(
      codePaths: toml.filePaths(update, transform, singularKey: "codePath", pluralKey: "codePaths"),
      subpathsToIgnore: toml.array(update, transform, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore,
      localizablePaths: toml.filePaths(
        update,
        transform,
        singularKey: "localizablePath",
        pluralKey: "localizablePaths"
      ),
      transformer: transformer,
      supportedLanguageEnumPath: toml.string(update, transform, "supportedLanguageEnumPath") ?? ".",
      typeName: toml.string(update, transform, "typeName") ?? "BartyCrouch",
      translateMethodName: toml.string(update, transform, "translateMethodName") ?? "translate",
      customLocalizableName: toml.string(update, transform, "customLocalizableName"),
      separateWithEmptyLine: toml.bool(update, transform, "separateWithEmptyLine") ?? true
    )
  }

  func tomlContents() -> String {
    var lines: [String] = ["[update.transform]"]

    lines.append("codePaths = \(self.codePaths)")
    lines.append("subpathsToIgnore = \(self.subpathsToIgnore)")
    lines.append("localizablePaths = \(self.localizablePaths)")
    lines.append(#"transformer = "\#(self.transformer.rawValue)""#)
    lines.append(#"supportedLanguageEnumPath = "\#(self.supportedLanguageEnumPath)""#)
    lines.append(#"typeName = "\#(self.typeName)""#)
    lines.append(#"translateMethodName = "\#(self.translateMethodName)""#)

    if let customLocalizableName = customLocalizableName {
      lines.append(#"customLocalizableName = "\#(customLocalizableName)""#)
    }

    lines.append("separateWithEmptyLine = \(self.separateWithEmptyLine)")

    return lines.joined(separator: "\n")
  }
}
