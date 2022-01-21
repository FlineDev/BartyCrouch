import Foundation
import SwiftCLI

// NOTE:
// This file was not refactored as port of the work/big-refactoring branch for version 4.0 to prevent unexpected behavior changes.
// A rewrite after writing extensive tests for the expected behavior could improve readebility, extensibility and performance.

enum CodeCommanderError: Error {
  case missingPath
  case pathNotADirectory
  case enumeratorCreationFailed
  case findFilesFailed
}

private enum CodeCommanderConstants {
  static let sourceCodeExtensions: Set<String> = ["h", "m", "mm", "swift"]
}

/// Sends `xcrun extractLocStrings` commands with specified input/output paths to bash.
public final class CodeCommander {
  // MARK: - Stored Type Properties
  public static let shared = CodeCommander()

  // MARK: - Instance Methods
  public func export(
    stringsFilesToPath stringsFilePath: String,
    fromCodeInDirectoryPath codeDirectoryPath: String,
    customFunction: String?,
    usePlistArguments: Bool,
    subpathsToIgnore: [String]
  ) throws {
    let files = try findFiles(in: codeDirectoryPath, subpathsToIgnore: subpathsToIgnore)
    let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []

    let argumentsWithoutTheFiles = ["extractLocStrings"] + ["-o", stringsFilePath] + customFunctionArgs + ["-q"]

    let arguments = try appendFiles(
      files,
      inListOfArguments: argumentsWithoutTheFiles,
      usePlistArguments: usePlistArguments
    )
    try Task.run("/usr/bin/xcrun", arguments: arguments)
  }

  func findFiles(in codeDirectoryPath: String, subpathsToIgnore: [String]) throws -> [String] {
    let fileManager = FileManager.default

    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: codeDirectoryPath, isDirectory: &isDirectory) else {
      throw CodeCommanderError.missingPath
    }

    guard isDirectory.boolValue else {
      throw CodeCommanderError.pathNotADirectory
    }

    guard
      let enumerator = fileManager.enumerator(
        at: URL(fileURLWithPath: codeDirectoryPath),
        includingPropertiesForKeys: []
      )
    else {
      throw CodeCommanderError.enumeratorCreationFailed
    }

    var matchedFiles = [String]()
    let codeFilesSearch = CodeFilesSearch(baseDirectoryPath: codeDirectoryPath)

    while let anURL = enumerator.nextObject() as? URL {
      if CodeCommanderConstants.sourceCodeExtensions.contains(anURL.pathExtension)
        && !codeFilesSearch.shouldSkipFile(at: anURL, subpathsToIgnore: subpathsToIgnore)
      {
        matchedFiles.append(anURL.path)
      }
    }

    return matchedFiles
  }

  // In the existing list of arguments it appends also the files arguments.
  func appendFiles(
    _ files: [String],
    inListOfArguments existingArguments: [String],
    usePlistArguments: Bool
  ) throws -> [String] {
    if usePlistArguments {
      let fileArgumentsPlistFile = try ExtractLocStrings().writeFilesArgumentsInPlist(files)
      return existingArguments + ["-f", fileArgumentsPlistFile]
    }
    else {
      let completeArgumentList = existingArguments + files
      return completeArgumentList
    }
  }
}
