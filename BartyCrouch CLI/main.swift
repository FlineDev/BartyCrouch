//
//  main.swift
//  BartyCrouch CLI
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation
import BartyCrouch

let currentPath = Process.arguments[0]

let inputStoryboardArguments = ["--input-storyboard", "-in"]
let outputStringsFilesArguments = ["--output-strings-files", "-out"]

func run() {
    
    let inputStoryboardIndexOptional: Int? = {
        for inputStoryboardArgument in inputStoryboardArguments {
            if let index = Process.arguments.indexOf(inputStoryboardArgument) {
                return index
            }
        }
        return nil
    }()
    
    guard let inputStoryboardIndex = inputStoryboardIndexOptional else {
        print("Error! Missing input key '\(inputStoryboardArguments[0])' or '\(inputStoryboardArguments[1])'")
        return
    }
    
    guard inputStoryboardIndex+1 <= Process.arguments.count else {
        print("Error! Missing input path after key '\(inputStoryboardArguments[0])' or '\(inputStoryboardArguments[1])'")
        return
    }
    
    let inputStoryboardPath = Process.arguments[inputStoryboardIndex+1]
    
    let outputStringsFilesIndexOptional: Int? = {
        for outputStringsFilesArgument in outputStringsFilesArguments {
            if let index = Process.arguments.indexOf(outputStringsFilesArgument) {
                return index
            }
        }
        return nil
    }()
    
    guard let outputStringsFilesIndex = outputStringsFilesIndexOptional else {
        print("Error! Missing output key '\(outputStringsFilesArguments[0])' or '\(outputStringsFilesArguments[1])'")
        return
    }
    
    guard outputStringsFilesIndex+1 <= Process.arguments.count else {
        print("Error! Missing input path after key '\(outputStringsFilesArguments[0])' or '\(outputStringsFilesArguments[1])'")
        return
    }

    let outputStringsFilesPaths = Process.arguments[outputStringsFilesIndex+1].componentsSeparatedByString(",")
    
    guard NSFileManager.defaultManager().fileExistsAtPath(inputStoryboardPath) else {
        print("Error! No file exists at input path '\(inputStoryboardPath)'")
        return
    }
    
    for outputStringsFilePath in outputStringsFilesPaths {
        guard NSFileManager.defaultManager().fileExistsAtPath(outputStringsFilePath) else {
            print("Error! No file exists at output path '\(outputStringsFilePath)'")
            return
        }
    }
    
    let extractedStringsFilePath = inputStoryboardPath + ".tmpstrings"
    
    guard IBToolCommander.sharedInstance.export(stringsFileToPath: extractedStringsFilePath, fromStoryboardAtPath: inputStoryboardPath) else {
        print("Error! Could not extract strings from Storyboard at path '\(inputStoryboardPath)'")
        return
    }
    
    for outputStringsFilePath in outputStringsFilesPaths {
        
        guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
            print("Error! Could not update strings file at path '\(outputStringsFilePath)'")
            return
        }
        
        stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath)
        
    }
    
    do {
        try NSFileManager.defaultManager().removeItemAtPath(extractedStringsFilePath)
        print("BartyCrouch: Successfully updated Strings files from Storyboard.")
    } catch {
        print("Error! Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'")
        return
    }
    
    
}

run()