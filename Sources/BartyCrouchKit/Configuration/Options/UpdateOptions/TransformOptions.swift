import Foundation
import MungoHealer
import Toml

struct TransformOptions {
    let codePaths: [String]
    let localizablePaths: [String]
    let transformer: Transformer
    let supportedLanguageEnumPath: String
    let typeName: String
    let translateMethodName: String
    let customLocalizableName: String?
}

extension TransformOptions: TomlCodable {
    static func make(toml: Toml) throws -> TransformOptions {
        let update: String = "update"
        let transform: String = "transform"

        guard let transformer = Transformer(rawValue: toml.string(update, transform, "transformer") ?? Transformer.foundation.rawValue) else {
            throw MungoError(
                source: .invalidUserInput,
                message: "Unknown `transformer` provided in [update.code.transform]. Supported: \(Transformer.allCases)"
            )
        }

        return TransformOptions(
            codePaths: toml.filePaths(update, transform, singularKey: "codePath", pluralKey: "codePaths"),
            localizablePaths: toml.filePaths(update, transform, singularKey: "localizablePath", pluralKey: "localizablePaths"),
            transformer: transformer,
            supportedLanguageEnumPath: toml.string(update, transform, "supportedLanguageEnumPath") ?? ".",
            typeName: toml.string(update, transform, "typeName") ?? "BartyCrouch",
            translateMethodName: toml.string(update, transform, "translateMethodName") ?? "translate",
            customLocalizableName: toml.string(update, transform, "customLocalizableName")
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.transform]"]

        lines.append("codePaths = \(codePaths)")
        lines.append("localizablePaths = \(localizablePaths)")
        lines.append("transformer = \"\(transformer.rawValue)\"")
        lines.append("supportedLanguageEnumPath = \"\(supportedLanguageEnumPath)\"")
        lines.append("typeName = \"\(typeName)\"")
        lines.append("translateMethodName = \"\(translateMethodName)\"")

        if let customLocalizableName = customLocalizableName {
            lines.append("customLocalizableName = \"\(customLocalizableName)\"")
        }

        return lines.joined(separator: "\n")
    }
}
