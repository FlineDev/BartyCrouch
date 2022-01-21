import Foundation
import SwiftCLI

public enum GlobalOptions {
  static let verbose = Flag(
    "-v",
    "--verbose",
    description: "Prints more detailed information about the executed command"
  )
  static let xcodeOutput = Flag(
    "-x",
    "--xcode-output",
    description: "Prints warnings & errors in Xcode compatible format"
  )
  static let failOnWarnings = Flag(
    "-w",
    "--fail-on-warnings",
    description: "Returns a failed status code if any warning is encountered"
  )
  static let path = Key<String>(
    "-p",
    "--path",
    description: "Specifies a different path than current to run BartyCrouch from there"
  )

  public static var all: [Option] {
    return [verbose, xcodeOutput, failOnWarnings, path]
  }

  static func setup() {
    if let path = path.value {
      FileManager.default.changeCurrentDirectoryPath(path)
    }
  }
}
