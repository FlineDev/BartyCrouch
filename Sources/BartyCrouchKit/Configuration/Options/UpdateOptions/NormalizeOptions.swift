// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct NormalizeOptions {
    let sourceLocale: String
    let harmonizeWithSource: Bool
    let sortByKeys: Bool
}

extension NormalizeOptions: TomlCodable {
    static func make(toml: Toml) throws -> NormalizeOptions {
        let update: String = "update"
        let normalize: String = "normalize"

        return NormalizeOptions(
            sourceLocale: toml.string(update, normalize, "sourceLocale") ?? "en",
            harmonizeWithSource: toml.bool(update, normalize, "harmonizeWithSource") ?? true,
            sortByKeys: toml.bool(update, normalize, "sortByKeys") ?? true
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.normalize]"]

        lines.append("sourceLocale = \"\(sourceLocale)\"")
        lines.append("harmonizeWithSource = \(harmonizeWithSource)")
        lines.append("sortByKeys = \(sortByKeys)")

        return lines.joined(separator: "\n")
    }
}
