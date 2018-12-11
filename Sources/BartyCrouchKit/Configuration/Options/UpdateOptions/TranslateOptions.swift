// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct TranslateOptions {
    enum API: String, CaseIterable {
        case bing
        case google
    }

    let path: String
    let api: API
    let id: String
    let secret: String
    let sourceLocale: String
}

extension TranslateOptions: TomlCodable {
    static func make(toml: Toml) throws -> TranslateOptions {
        let update: String = "update"
        let translate: String = "translate"

        if
            let apiValue = toml.string(update, translate, "api"),
            let api: API = API(rawValue: apiValue),
            let id: String = toml.string(update, translate, "id"),
            let secret: String = toml.string(update, translate, "secret")
        {
            let path = toml.string(update, translate, "path") ?? "."
            let sourceLocale: String = toml.string(update, translate, "sourceLocale") ?? "en"
            return TranslateOptions(path: path, api: api, id: id, secret: secret, sourceLocale: sourceLocale)
        } else {
            throw MungoError(source: .invalidUserInput, message: "Incomplete [update.translate] options provided, ignoring them all.")
        }
    }

    func tomlContents() -> String {
        var lines: [String] = ["[update.translate]"]

        lines.append("path = \"\(path)\"")
        lines.append("api = \"\(api.rawValue)\"")
        lines.append("id = \"\(id)\"")
        lines.append("secret = \"\(secret)\"")
        lines.append("sourceLocale = \"\(sourceLocale)\"")

        return lines.joined(separator: "\n")
    }
}
