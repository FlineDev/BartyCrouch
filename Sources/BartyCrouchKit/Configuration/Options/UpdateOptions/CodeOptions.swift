import Foundation
import Toml

struct CodeOptions {
    let codePaths: [String]
    let localizablePaths: [String]
    let defaultToKeys: Bool
    let additive: Bool
    let customFunction: String?
    let customLocalizableName: String?
    let unstripped: Bool
    let usesPlistForExtractLocStringsArguments: Bool?
}

extension CodeOptions: TomlCodable {
    static func make(toml: Toml) throws -> CodeOptions {
        let update: String = "update"
        let code: String = "code"

        return CodeOptions(
            codePaths: toml.filePaths(update, code, singularKey: "codePath", pluralKey: "codePaths"),
            localizablePaths: toml.filePaths(update, code, singularKey: "localizablePath", pluralKey: "localizablePaths"),
            defaultToKeys: toml.bool(update, code, "defaultToKeys") ?? false,
            additive: toml.bool(update, code, "additive") ?? true,
            customFunction: toml.string(update, code, "customFunction"),
            customLocalizableName: toml.string(update, code, "customLocalizableName"),
            unstripped: toml.bool(update, code, "unstripped") ?? false,
            usesPlistForExtractLocStringsArguments: toml.bool(update, code, "usesPlistForExtractLocStringsArguments")
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.code]"]

        lines.append("codePaths = \(codePaths)")
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

        if let usesPlistForExtractLocStringsArguments = usesPlistForExtractLocStringsArguments {
            lines.append("usesPlistForExtractLocStringsArguments = \(usesPlistForExtractLocStringsArguments)")
        }

        return lines.joined(separator: "\n")
    }
}
