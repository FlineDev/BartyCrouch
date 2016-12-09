//
//  ExtractLocStringsCommander.swift
//  BartyCrouch
//
//  Created by Fyodor Volchyok on 12.09.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Sends `xcrun extractLocStrings` commands with specified input/output paths to bash.
public class ExtractLocStringsCommander: CodeCommander {

    // MARK: - Stored Class Properties

    public static let sharedInstance = ExtractLocStringsCommander()


    // MARK: - Instance Methods

    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String) -> Bool {
        let findFilesResult = findFiles(in: codeDirectoryPath)

        let exportFileResult = Commander.sharedInstance.run(command: "/usr/bin/xcrun", arguments: ["extractLocStrings"] + findFilesResult.outputs + ["-o", stringsFilePath])

        return findFilesResult.exitCode == 0 && exportFileResult.exitCode == 0
    }

}
