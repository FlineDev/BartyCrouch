//
//  GenStringsCommander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Sends `genstrings` commands with specified input/output paths to bash.
public class GenStringsCommander {

    // MARK: - Stored Class Properties

    public static let sharedInstance = GenStringsCommander()


    // MARK: - Instance Methods

    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String) -> Bool {
        let findFilesResult = Commander.sharedInstance.run(command: "/usr/bin/find", arguments:
            [codeDirectoryPath, "-name", "*.[hm]", "-o", "-name", "*.mm", "-o", "-name", "*.swift"])

        let exportFileResult = Commander.sharedInstance.run(command: "/usr/bin/genstrings", arguments: findFilesResult.outputs + ["-o", stringsFilePath])

        if findFilesResult.exitCode == 0 && exportFileResult.exitCode == 0 {
            return true
        } else {
            return false
        }
    }

}
