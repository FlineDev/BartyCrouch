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
        usesPlistForExtractLocStringsArguments: Bool?
    ) throws {
        let files = try findFiles(in: codeDirectoryPath)
        let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []

        let argumentsWithoutTheFiles = ["extractLocStrings"] + ["-o", stringsFilePath] + customFunctionArgs + ["-q"]

        let arguments = try appendFiles(files, inListOfArguments: argumentsWithoutTheFiles, usesPlistForExtractLocStringsArguments)
        try Task.run("/usr/bin/xcrun", arguments: arguments)
    }

    func findFiles(in codeDirectoryPath: String) throws -> [String] {
        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: codeDirectoryPath, isDirectory: &isDirectory) else {
            throw CodeCommanderError.missingPath
        }

        guard isDirectory.boolValue else {
            throw CodeCommanderError.pathNotADirectory
        }

        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: codeDirectoryPath), includingPropertiesForKeys: []) else {
            throw CodeCommanderError.enumeratorCreationFailed
        }

        var matchedFiles = [String]()

        while let anURL = enumerator.nextObject() as? URL {
            if CodeCommanderConstants.sourceCodeExtensions.contains(anURL.pathExtension) {
                matchedFiles.append(anURL.path)
            }
        }

        return matchedFiles
    }

    // In the existing list of arguments it appends also the files arguments. Depending on the total length of the argument list we either append them in the
    // argument list or write them in a file and append that file.
    func appendFiles(_ files: [String], inListOfArguments existingArguments: [String], _ usesPlistForExtractLocStringsArguments: Bool?) throws -> [String] {
        let completeArgumentList = existingArguments + files
        let disableUsageOfPlistForArgumentList = !(usesPlistForExtractLocStringsArguments ?? true)
        let forceUsageOfPlistForArgumentList = usesPlistForExtractLocStringsArguments ?? false

        // If the flag is not set we will autodetect if we need to use a plist file
        if forceUsageOfPlistForArgumentList || ( !disableUsageOfPlistForArgumentList && Task.isArgumentListTooLong(completeArgumentList)) {
            // If the argument list gets to long we write the files in a plist and pass that as argument
            let fileArgumentsPlistFile = try ExtractLocStrings().writeFilesArgumentsInPlist(files)
            return existingArguments + ["-f", fileArgumentsPlistFile]
        } else {
            return completeArgumentList
        }
    }
}
