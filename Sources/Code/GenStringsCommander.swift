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
    
    public func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) -> Bool {
        
        let customFunctionAddon: String = customFunction != nil ? "-s '\(customFunction!)'" : ""
        let exitCode = system("find \"\(codeDirectoryPath)\" -name '*.[hm]' -o -name '*.swift' | xargs genstrings -o \"\(stringsFilePath)\" \(customFunctionAddon)")
        
        if exitCode == 0 {
            return true
        } else {
            return false
        }
    }
    
}