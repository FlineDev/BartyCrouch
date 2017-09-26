//
//  IBToolCommander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 11.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Sends `ibtool` commands with specified input/output paths to bash.
public class IBToolCommander {
    // MARK: - Stored Type Properties
    public static let shared = IBToolCommander()

    // MARK: - Instance Methods
    public func export(stringsFileToPath stringsFilePath: String, fromIbFileAtPath ibFilePath: String) -> Bool {
        let exportResult = Commander.shared.run(command: "/usr/bin/ibtool", arguments: ["--export-strings-file", stringsFilePath, ibFilePath])

        if exportResult.exitCode == 0 {
            return true
        } else {
            return false
        }
    }
}
