//  Created by Fyodor Volchyok on 12/9/16.

import Foundation
import SwiftCLI

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
public class CodeCommander {
    // MARK: - Stored Type Properties
    public static let shared = CodeCommander()

    // MARK: - Instance Methods
    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) throws {
        let files = try findFiles(in: codeDirectoryPath)
        let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []

        let arguments = ["extractLocStrings"] + files + ["-o", stringsFilePath] + customFunctionArgs
        try run("/usr/bin/xcrun", arguments: arguments)
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
}
