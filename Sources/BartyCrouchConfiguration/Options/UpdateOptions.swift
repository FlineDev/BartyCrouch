import Foundation
import MungoHealer
import Toml

public struct UpdateOptions {
  public enum Task: String {
    case interfaces
    case code
    case transform
    case translate
    case normalize
  }

  public let tasks: [Task]
  public let interfaces: InterfacesOptions
  public let code: CodeOptions
  public let transform: TransformOptions
  public let translate: TranslateOptions?
  public let normalize: NormalizeOptions
}

extension UpdateOptions: TomlCodable {
  static func make(toml: Toml) throws -> UpdateOptions {
    let translateOptions: TranslateOptions? = try? TranslateOptions.make(toml: toml)
    let defaultTasks: [String] =
      translateOptions != nil
      ? ["interfaces", "code", "transform", "translate", "normalize"]
      : ["interfaces", "code", "transform", "normalize"]

    return UpdateOptions(
      tasks: (toml.array("update", "tasks") ?? defaultTasks).compactMap { Task(rawValue: $0) },
      interfaces: try InterfacesOptions.make(toml: toml),
      code: try CodeOptions.make(toml: toml),
      transform: try TransformOptions.make(toml: toml),
      translate: translateOptions,
      normalize: try NormalizeOptions.make(toml: toml)
    )
  }

  func tomlContents() -> String {
    let sections: [String?] = [
      "[update]\ntasks = \(tasks.map { $0.rawValue })",
      interfaces.tomlContents(),
      code.tomlContents(),
      transform.tomlContents(),
      translate?.tomlContents(),
      normalize.tomlContents(),
    ]

    return sections.compactMap { $0 }.joined(separator: "\n\n")
  }
}
