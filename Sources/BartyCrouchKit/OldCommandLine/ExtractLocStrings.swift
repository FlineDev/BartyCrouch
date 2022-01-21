//  Created by Christos Koninis on 25/09/2019.

import Foundation

/// Class to handle extractLocStrings's tool file argument list. It provides methods to serialize the file list to an argument plist file. See
/// https://github.com/Flinesoft/BartyCrouch/issues/92
class ExtractLocStrings {
  /// extractLocStrings tools supports instead of passing files as arguments in the command line to pass a plist with the files. This is the format of that
  /// plist.
  struct File: Codable, Equatable {
    var path: String
  }
  struct ArgumentsPlist: Codable, Equatable {
    var files: [File] = []

    init(
      filePaths: [String]
    ) {
      files = filePaths.map(File.init)
    }
  }

  /// Serializes the extractLocStrings's file arguments to an argument plist file.
  ///
  /// - Parameter files: A array containing the list of files.
  /// - Returns: The argument plist file that contains the list of file arguments.
  /// - Throws: An error if any value throws an error during plist encoding.
  func writeFilesArgumentsInPlist(_ files: [String]) throws -> String {
    let data = try encodeFilesArguments(files)
    let tempPlistFilePath = createTemporaryArgumentsPlistFile()
    try data.write(to: tempPlistFilePath)

    return tempPlistFilePath.path
  }

  /// Serializes the extractLocStrings's file arguments to byte array
  ///
  /// - Parameter files: A array containing the list of files.
  /// - Returns: A plist encoded value of the supplied array
  func encodeFilesArguments(_ files: [String]) throws -> Data {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml

    return try encoder.encode(ArgumentsPlist(filePaths: files))
  }

  private func createTemporaryArgumentsPlistFile() -> URL {
    let temporaryFilename = ProcessInfo().globallyUniqueString
    var temporaryPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    temporaryPath.appendPathComponent(temporaryFilename)
    temporaryPath.appendPathExtension("plist")

    return temporaryPath
  }
}
