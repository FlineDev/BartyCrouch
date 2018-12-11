// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct UpdateOptions {
    let interfaces: InterfacesOptions
    let code: CodeOptions
    let translate: TranslateOptions?
    let normalize: NormalizeOptions
}

extension UpdateOptions: TomlCodable {
    static func make(toml: Toml) throws -> UpdateOptions {
        return UpdateOptions(
            interfaces: try InterfacesOptions.make(toml: toml),
            code: try CodeOptions.make(toml: toml),
            translate: try? TranslateOptions.make(toml: toml),
            normalize: try NormalizeOptions.make(toml: toml)
        )
    }

    func tomlContents() -> String {
        let sections: [String?] = [
            interfaces.tomlContents(),
            code.tomlContents(),
            translate?.tomlContents(),
            normalize.tomlContents()
        ]

        return sections.compactMap { $0 }.joined(separator: "\n\n")
    }
}
