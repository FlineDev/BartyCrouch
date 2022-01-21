import Foundation
import SwiftCLI

public class InitCommand: Command {
  // MARK: - Command
  public let name: String = "init"
  public let shortDescription: String =
    "Creates the default configuration file & creates a build script if Xcode project found"

  // MARK: - Initializers
  public init() {}

  // MARK: - Instance Methods
  public func execute() throws {
    GlobalOptions.setup()
    InitTaskHandler().perform()
    CommandExecution.current.failIfNeeded()
  }
}
