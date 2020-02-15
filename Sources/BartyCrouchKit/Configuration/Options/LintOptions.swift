import Foundation
import MungoHealer
import Toml

struct LintOptions {
    let paths: [String]
    let duplicateKeys: Bool
    let emptyValues: Bool
}

extension LintOptions: TomlCodable {
    static func make(toml: Toml) throws -> LintOptions {
        let lint: String = "lint"

        return LintOptions(
            paths: toml.array(lint, "paths") ?? [toml.string(lint, "path") ?? toml.string(lint, "paths") ?? "."],
            duplicateKeys: toml.bool(lint, "duplicateKeys") ?? true,
            emptyValues: toml.bool(lint, "emptyValues") ?? true
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[lint]"]

        lines.append("paths = \"\(Toml.convertToString(paths))\"")
        lines.append("duplicateKeys = \(duplicateKeys)")
        lines.append("emptyValues = \(emptyValues)")

        return lines.joined(separator: "\n")
    }
}
