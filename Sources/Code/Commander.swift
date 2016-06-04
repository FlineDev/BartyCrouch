//
//  Commander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 04.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

class Commander {
    
    // MARK: - Define Sub Structures
    
    typealias CommandLineResult = (outputs: [String], errors: [String], exitCode: Int32)
    
    
    // MARK: - Stored Class Properties
    
    static let sharedInstance = Commander()

    
    // MARK: - Instance Methods
    
    func run(command: String, arguments: [String]?) -> CommandLineResult {
        
        let task = NSTask()
        task.launchPath = command
        task.arguments = arguments
        
        let outpipe = NSPipe()
        task.standardOutput = outpipe
        let errpipe = NSPipe()
        task.standardError = errpipe
        
        task.launch()
        
        var outputs: [String] = []
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        
        if var string = String.fromCString(UnsafePointer(outdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            outputs = string.componentsSeparatedByString("\n")
        }
        
        var errors: [String] = []
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        
        if var string = String.fromCString(UnsafePointer(errdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            errors = string.componentsSeparatedByString("\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (outputs, errors, status)
    }
    
}
