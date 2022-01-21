import Foundation

final class CommandExecution {
  static let current = CommandExecution()

  var didPrintWarning: Bool = false

  func failIfNeeded() {
    if GlobalOptions.failOnWarnings.value && didPrintWarning {
      exit(EXIT_FAILURE)
    }
  }
}
