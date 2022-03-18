import Foundation
import MungoHealer

let mungo = MungoHealer(errorHandler: CommandLineErrorHandler())

struct CommandLineErrorHandler: ErrorHandler {
  func handle(error: Error) {
    log(error, level: .warning)
  }

  func handle(baseError: BaseError) {
    log(baseError, level: .warning)
  }

  func handle(fatalError: FatalError) {
    log(fatalError, level: .error)
    crash()
  }

  func handle(healableError: HealableError) {  // swiftlint:disable:this unavailable_function
    log(healableError, level: .info)
    fatalError("Healable Errors not supported by \(String(describing: CommandLineErrorHandler.self)).")
  }

  private func log(_ error: Error, level: PrintLevel) {
    if GlobalOptions.verbose.value, let baseError = error as? BaseError,
      let debugDescription = baseError.debugDescription, !debugDescription.isBlank
    {
      print("\(error.localizedDescription) | Details: \(debugDescription)", level: level)
    }
    else {
      print(error.localizedDescription, level: level)
    }
  }

  private func crash() {
    exit(EXIT_FAILURE)
  }
}
