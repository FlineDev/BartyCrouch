// Created by Cihat Gündüz on 06.11.18.

import Foundation
import MungoHealer
import Toml

struct UpdateOptions {
    enum Task: String {
        case interfaces
        case code
        case translate
        case normalize
    }

    let tasks: [Task]
    let interfaces: InterfacesOptions
    let code: CodeOptions
    let translate: TranslateOptions?
    let normalize: NormalizeOptions
}

extension UpdateOptions: TomlCodable {
    static func make(toml: Toml) throws -> UpdateOptions {
        let translateOptions: TranslateOptions? = try? TranslateOptions.make(toml: toml)
        let defaultTasks: [String] = translateOptions != nil ? ["interfaces", "code", "translate", "normalize"] : ["interfaces", "code", "normalize"]

        return UpdateOptions(
            tasks: (toml.array("update", "tasks") ?? defaultTasks).compactMap { Task(rawValue: $0) },
            interfaces: try InterfacesOptions.make(toml: toml),
            code: try CodeOptions.make(toml: toml),
            translate: translateOptions,
            normalize: try NormalizeOptions.make(toml: toml)
        )
    }

    func tomlContents() -> String {
        let sections: [String?] = [
            "[update]\ntasks = \(tasks.map { $0.rawValue })",
            interfaces.tomlContents(),
            code.tomlContents(),
            translate?.tomlContents(),
            normalize.tomlContents()
        ]

        return sections.compactMap { $0 }.joined(separator: "\n\n")
    }
}
