import Foundation
import MungoHealer
import Toml

struct TranslateOptions {
    let paths: [String]
    let secret: Secret
    let sourceLocale: String
}

enum Translator: String {
    case microsoftTranslator
    case deepl
}

extension TranslateOptions: TomlCodable {
    static func make(toml: Toml) throws -> TranslateOptions {
        let update: String = "update"
        let translate: String = "translate"

        if let secretString: String = toml.string(update, translate, "secret") {
            let translator = toml.string(update, translate, "translator") ?? Translator.microsoftTranslator.rawValue
            let paths = toml.filePaths(update, translate, singularKey: "path", pluralKey: "paths")
            let sourceLocale: String = toml.string(update, translate, "sourceLocale") ?? "en"
            let secret: Secret
            switch Translator(rawValue: translator) {
            case .microsoftTranslator, .none:
                secret = .microsoftTranslator(secret: secretString)
            case .deepl:
                secret = .deepl(secret: secretString)
            }
            return TranslateOptions(paths: paths, secret: secret, sourceLocale: sourceLocale)
        } else {
            throw MungoError(source: .invalidUserInput, message: "Incomplete [update.translate] options provided, ignoring them all.")
        }
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.translate]"]

        lines.append("paths = \(paths)")
        lines.append("secret = \"\(secret)\"")
        lines.append("sourceLocale = \"\(sourceLocale)\"")

        return lines.joined(separator: "\n")
    }
}
