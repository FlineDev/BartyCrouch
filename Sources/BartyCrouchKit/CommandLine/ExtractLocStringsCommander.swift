//  Created by Fyodor Volchyok on 12.09.16.

import Foundation

/// Sends `xcrun extractLocStrings` commands with specified input/output paths to bash.
public class ExtractLocStringsCommander: CodeCommander {
    // MARK: - Stored Type Properties
    public static let shared = ExtractLocStringsCommander()

    // MARK: - Instance Methods
    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) -> Bool {
        let findFilesResult = findFiles(in: codeDirectoryPath)
        let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []
        let exportFileResult = Commander.shared.run(
            command: "/usr/bin/xcrun",
            arguments: ["extractLocStrings"] + findFilesResult.outputs + ["-o", stringsFilePath] + customFunctionArgs
        )
        return findFilesResult.exitCode == 0 && exportFileResult.exitCode == 0
    }
}
