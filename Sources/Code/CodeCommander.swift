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

private struct CodeCommanderConstants {
    static let sourceCodeExtensions: Set<String> = ["h", "m", "mm", "swift"]
}

extension CodeCommander {
    func findFiles(in codeDirectoryPath: String) -> Commander.CommandLineResult {
        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: codeDirectoryPath, isDirectory: &isDirectory) else {
            return ([], [codeDirectoryPath + "doesn't exist"], 1)
        }

        guard isDirectory.boolValue else {
            return ([], [codeDirectoryPath + "isn't a directory"], 1)
        }

        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: codeDirectoryPath), includingPropertiesForKeys: []) else {
            return ([], ["failed to create enumerator for " + codeDirectoryPath], 1)
        }

        var matchedFiles = [String]()

        while let anURL = enumerator.nextObject() as? URL {
            if CodeCommanderConstants.sourceCodeExtensions.contains(anURL.pathExtension) {
                matchedFiles.append(anURL.path)
            }
        }

        return (matchedFiles, [], 0)
    }
}
