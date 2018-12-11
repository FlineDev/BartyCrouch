// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct InterfacesOptions {
    let defaultToBase: Bool
    let ignoreEmptyString: Bool
}

extension InterfacesOptions: TomlCodable {
    static func make(toml: Toml) throws -> InterfacesOptions {
        let update: String = "update"
        let interfaces: String = "interfaces"

        return InterfacesOptions(
            defaultToBase: toml.bool(update, interfaces, "defaultToBase") ?? false,
            ignoreEmptyString: toml.bool(update, interfaces, "ignoreEmptyString") ?? false
        )
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.interfaces]"]

        lines.append("defaultToBase = \(defaultToBase)")
        lines.append("ignoreEmptyString = \(ignoreEmptyString)")

        return lines.joined(separator: "\n")
    }
}
