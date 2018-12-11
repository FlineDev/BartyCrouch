// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct GlobalOptions {
    let sourceLocale: String
    let unstripped: Bool
}

extension GlobalOptions: TomlCodable {
    static func make(toml: Toml) throws -> GlobalOptions {
        let global: String = "global"

        return GlobalOptions(
            sourceLocale: toml.string(global, "sourceLocale") ?? "en",
            unstripped: toml.bool(global, "unstripped") ?? false
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[global]"]

        lines.append("sourceLocale = \"\(sourceLocale)\"")
        lines.append("unstripped = \(unstripped)")

        return lines.joined(separator: "\n")
    }
}
