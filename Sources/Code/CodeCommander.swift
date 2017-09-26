//
//  CodeCommander.swift
//  BartyCrouch
//
//  Created by Fyodor Volchyok on 12/9/16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

protocol CodeCommander {
    func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) -> Bool
}

extension CodeCommander {
    func findFiles(in codeDirectoryPath: String) -> Commander.CommandLineResult {
        return Commander.shared.run(
            command: "/usr/bin/find",
            arguments: [codeDirectoryPath, "-name", "*.[hm]", "-o", "-name", "*.mm", "-o", "-name", "*.swift"]
        )
    }
}
