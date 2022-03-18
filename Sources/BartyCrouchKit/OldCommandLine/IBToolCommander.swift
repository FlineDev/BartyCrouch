import Foundation
import SwiftCLI

// NOTE:
// This file was not refactored as port of the work/big-refactoring branch for version 4.0 to prevent unexpected behavior changes.
// A rewrite after writing extensive tests for the expected behavior could improve readebility, extensibility and performance.

/// Sends `ibtool` commands with specified input/output paths to bash.
public final class IBToolCommander {
  // MARK: - Stored Type Properties
  public static let shared = IBToolCommander()

  // MARK: - Instance Methods
  public func export(stringsFileToPath stringsFilePath: String, fromIbFileAtPath ibFilePath: String) throws {
    let arguments = ["--export-strings-file", stringsFilePath, ibFilePath]
    try Task.run("/usr/bin/ibtool", arguments: arguments)
  }
}
