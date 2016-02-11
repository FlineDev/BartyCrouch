//
//  main.swift
//  BartyCrouch CLI
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

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
        print("missing input key '\(inputStoryboardArguments[0])' or '\(inputStoryboardArguments[1])'")
        return
    }
    
    guard inputStoryboardIndex+1 <= Process.arguments.count else {
        print("missing input path after key '\(inputStoryboardArguments[0])' or '\(inputStoryboardArguments[1])'")
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
        print("missing output key '\(outputStringsFilesArguments[0])' or '\(outputStringsFilesArguments[1])'")
        return
    }
    
    guard outputStringsFilesIndex+1 <= Process.arguments.count else {
        print("missing input path after key '\(outputStringsFilesArguments[0])' or '\(outputStringsFilesArguments[1])'")
        return
    }

    let outputStringsFilesPaths = Process.arguments[outputStringsFilesIndex+1].componentsSeparatedByString(",")
    

    print("Trying to extract strings from Storyboard at path '\(inputStoryboardPath)' to Strings files at paths '\(outputStringsFilesPaths)'...")
}

run()