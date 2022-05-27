import BartyCrouchUtility
import Foundation
import MungoHealer
import Toml

public enum Translator: String {
  case microsoftTranslator
  case deepL
}

public struct TranslateOptions {
  public let paths: [String]
  public let subpathsToIgnore: [String]
  public let secret: Secret
  public let sourceLocale: String
  public let separateWithEmptyLine: Bool
}

extension TranslateOptions: TomlCodable {
  static func make(toml: Toml) throws -> TranslateOptions {
    let update: String = "update"
    let translate: String = "translate"

    if let secretString: String = toml.string(update, translate, "secret") {
      let translator = toml.string(update, translate, "translator") ?? "microsoftTranslator"
      let paths = toml.filePaths(update, translate, singularKey: "path", pluralKey: "paths")
      let subpathsToIgnore = toml.array(update, translate, "subpathsToIgnore") ?? Constants.defaultSubpathsToIgnore
      let sourceLocale: String = toml.string(update, translate, "sourceLocale") ?? "en"
      let separateWithEmptyLine = toml.bool(update, translate, "separateWithEmptyLine") ?? true
      let secret: Secret
      switch Translator(rawValue: translator) {
      case .microsoftTranslator, .none:
        secret = .microsoftTranslator(secret: secretString)

      case .deepL:
        secret = .deepL(secret: secretString)
      }

      return TranslateOptions(
        paths: paths,
        subpathsToIgnore: subpathsToIgnore,
        secret: secret,
        sourceLocale: sourceLocale,
        separateWithEmptyLine: separateWithEmptyLine
      )
    }
    else {
      throw MungoError(
        source: .invalidUserInput,
        message: "Incomplete [update.translate] options provided, ignoring them all."
      )
    }
  }

  func tomlContents() -> String {
    var lines: [String] = ["[update.translate]"]

    lines.append("paths = \(paths)")
    lines.append("subpathsToIgnore = \(subpathsToIgnore)")
    switch secret {
    case let .deepL(secret):
      lines.append(#"secret = "\#(secret)""#)

    case let .microsoftTranslator(secret):
      lines.append(#"secret = "\#(secret)""#)
    }

    lines.append(#"sourceLocale = "\#(sourceLocale)""#)
    lines.append("separateWithEmptyLine = \(self.separateWithEmptyLine)")

    return lines.joined(separator: "\n")
  }
}
