import Foundation
import Toml

struct NormalizeOptions {
    let paths: [String]
    let sourceLocale: String
    let harmonizeWithSource: Bool
    let sortByKeys: Bool
}

extension NormalizeOptions: TomlCodable {
    static func make(toml: Toml) throws -> NormalizeOptions {
        let update: String = "update"
        let normalize: String = "normalize"

        return NormalizeOptions(
            paths: toml.array(update, normalize, "paths") ?? [toml.string(update, normalize, "path") ?? "."],
            sourceLocale: toml.string(update, normalize, "sourceLocale") ?? "en",
            harmonizeWithSource: toml.bool(update, normalize, "harmonizeWithSource") ?? true,
            sortByKeys: toml.bool(update, normalize, "sortByKeys") ?? true
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.normalize]"]

        lines.append("paths = \"\(paths)\"")
        lines.append("sourceLocale = \"\(sourceLocale)\"")
        lines.append("harmonizeWithSource = \(harmonizeWithSource)")
        lines.append("sortByKeys = \(sortByKeys)")

        return lines.joined(separator: "\n")
    }
}
