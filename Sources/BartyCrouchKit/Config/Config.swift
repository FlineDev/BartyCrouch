// Created by Cihat Gündüz on 06.11.18.

import Foundation

struct Config: Codable {
    let included: [String]
    let excluded: [String]
    let global: GlobalOptions
    let update: UpdateOptions
    let lint: LintOptions

    static var makeDefault: Config {
        return Config(
            included: [],
            excluded: ["Carthage/", "Pods/"],
            global: GlobalOptions(sourceLocale: "en", unstripped: false),
            update: UpdateOptions(
                interface: InterfacesOptions(defaultToBase: false, ignoreEmptyString: true),
                code: CodeOptions(defaultToKeys: false, additive: true, customFunction: nil, customLocalizableName: nil),
                translate: TranslateOptions(api: .bing, id: nil, secret: nil),
                normalize: NormalizeOptions(harmonizeWithSource: true, sortByKeys: true)
            ),
            lint: LintOptions(duplicateKeys: true, emptyValues: true)
        )
    }

    static func load() -> Config {
        let configUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".bartycrouch.json")

        if let configData = try? Data(contentsOf: configUrl), let config = try? JSONDecoder().decode(Config.self, from: configData) {
            return config
        }

        return makeDefault
    }
}
