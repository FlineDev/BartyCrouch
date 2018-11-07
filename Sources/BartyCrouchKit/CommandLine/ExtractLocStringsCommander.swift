//  Created by Fyodor Volchyok on 12.09.16.

import Foundation
import SwiftCLI

enum ExtractLocStringsError: Error {
    case findFilesFailed
}

/// Sends `xcrun extractLocStrings` commands with specified input/output paths to bash.
public class ExtractLocStringsCommander: CodeCommander {
    // MARK: - Stored Type Properties
    public static let shared = ExtractLocStringsCommander()

    // MARK: - Instance Methods
    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) throws {
        let files = try findFiles(in: codeDirectoryPath)
        let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []

        let arguments = ["extractLocStrings"] + files + ["-o", stringsFilePath] + customFunctionArgs
        try run("/usr/bin/xcrun", arguments: arguments)
    }
}
