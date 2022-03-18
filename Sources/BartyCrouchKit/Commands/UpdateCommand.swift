import BartyCrouchConfiguration
import Foundation
import SwiftCLI

public class UpdateCommand: Command {
  // MARK: - Command
  public let name: String = "update"
  public let shortDescription: String =
    "Update your .strings file contents with the configured tasks (default: interfaces, code, normalize)"

  // MARK: - Initializers
  public init() {}

  // MARK: - Instance Methods
  public func execute() throws {
    GlobalOptions.setup()
    let updateOptions = try Configuration.load().updateOptions

    for task in updateOptions.tasks {
      let taskHandler: TaskHandler = {
        switch task {
        case .interfaces:
          return InterfacesTaskHandler(options: updateOptions.interfaces)

        case .code:
          return CodeTaskHandler(options: updateOptions.code)

        case .transform:
          return TransformTaskHandler(options: updateOptions.transform)

        case .translate:
          return TranslateTaskHandler(options: updateOptions.translate!)

        case .normalize:
          return NormalizeTaskHandler(options: updateOptions.normalize)
        }
      }()

      taskHandler.perform()
    }

    CommandExecution.current.failIfNeeded()
  }
}
