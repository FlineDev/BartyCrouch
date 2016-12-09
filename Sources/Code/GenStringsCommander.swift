//
//  GenStringsCommander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Sends `genstrings` commands with specified input/output paths to bash.
public class GenStringsCommander: CodeCommander {

    // MARK: - Stored Class Properties

    public static let sharedInstance = GenStringsCommander()


    // MARK: - Instance Methods

    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String) -> Bool {
        let findFilesResult = findFiles(in: codeDirectoryPath)

        let exportFileResult = Commander.sharedInstance.run(command: "/usr/bin/genstrings", arguments: findFilesResult.outputs + ["-o", stringsFilePath])

        return findFilesResult.exitCode == 0 && exportFileResult.exitCode == 0
    }

}
