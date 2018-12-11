// Created by Cihat Gündüz on 08.11.18.

import Foundation
import MungoHealer
import Toml

struct Configuration {
    static let fileName: String = ".bartycrouch.toml"

    let updateOptions: UpdateOptions
    let lintOptions: LintOptions

    static func load() throws -> Configuration {
        let configUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(Configuration.fileName)

        guard FileManager.default.fileExists(atPath: configUrl.path) else {
            return try Configuration.make(toml: try Toml(withString: ""))
        }

        let toml: Toml = try Toml(contentsOfFile: configUrl.path)
        return try Configuration.make(toml: toml)
    }
}

extension Configuration: TomlCodable {
    static func make(toml: Toml) throws -> Configuration {
        let updateOptions = try UpdateOptions.make(toml: toml)
        let lintOptions = try LintOptions.make(toml: toml)

        return Configuration(updateOptions: updateOptions, lintOptions: lintOptions)
    }

    func tomlContents() -> String {
        let sections: [String] = [
            updateOptions.tomlContents(),
            lintOptions.tomlContents()
        ]

        return sections.joined(separator: "\n\n") + "\n"
    }
}
