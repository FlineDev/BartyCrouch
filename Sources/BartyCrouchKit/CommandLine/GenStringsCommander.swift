//  Created by Cihat Gündüz on 03.05.16.

import Foundation

/// Sends `genstrings` commands with specified input/output paths to bash.
public class GenStringsCommander: CodeCommander {
    // MARK: - Stored Type Properties
    public static let shared = GenStringsCommander()

    // MARK: - Instance Methods
    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) -> Bool {
        let findFilesResult = findFiles(in: codeDirectoryPath)
        let customFunctionArgs = customFunction != nil ? ["-s", "\(customFunction!)"] : []
        let exportFileResult = Commander.shared.run(
            command: "/usr/bin/genstrings",
            arguments: findFilesResult.outputs + ["-o", stringsFilePath] + customFunctionArgs
        )
        return findFilesResult.exitCode == 0 && exportFileResult.exitCode == 0
    }
}
