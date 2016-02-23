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

    // MARK: - Stored Class Properties
    
    public static let sharedInstance = IBToolCommander()
    
    
    // MARK: - Instance Methods
    
    public func export(stringsFileToPath stringsFilePath: String, fromIbFileAtPath ibFilePath: String) -> Bool {
        let (_, exitCode) = self.shell(["ibtool", "--export-strings-file", stringsFilePath, ibFilePath])
        
        if exitCode == 0 {
            return true
        } else {
            return false
        }
    }
    
    func shell(arguments: [String]) -> (output: String, exitCode: Int32) {
        let task = NSTask()
        task.launchPath = "/usr/bin/env"
        task.arguments = arguments
        task.environment = [
            "LC_ALL" : "en_US.UTF-8",
            "HOME" : NSHomeDirectory()
        ]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        return (output, task.terminationStatus)
    }
    
}
