import BartyCrouchKit
import Foundation
import SwiftCLI

// MARK: - CLI
let cli = CLI(
  name: "bartycrouch",
  version: "4.12.0",
  description: "Incrementally update & translate your Strings files from code or interface files."
)

cli.commands = [InitCommand(), UpdateCommand(), LintCommand()]
cli.globalOptions.append(contentsOf: GlobalOptions.all)
cli.goAndExit()
