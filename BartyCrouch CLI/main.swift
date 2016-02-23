//
//  main.swift
//  BartyCrouch CLI
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation


// Configure command line interface

let cli = CommandLine()

let input = StringOption(
    shortFlag: "i",
    longFlag: "input",
    required: true,
    helpMessage: "Path to your Storyboard or XIB source file to be translated."
)

let output = MultiStringOption(
    shortFlag: "o",
    longFlag: "output",
    required: false,
    helpMessage: "A list of paths to your strings files to be incrementally updated."
)

let auto = BoolOption(
    shortFlag: "a",
    longFlag: "auto",
    required: false,
    helpMessage: "Automatically finds all strings files to update based on the Xcode defaults."
)

cli.addOptions(input, output, auto)


// Parse input data or exit with usage instructions

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}


// Do requested action(s)

enum OutputType {
    case StringsFiles
    case Automatic
    case None
}

func run() {

    let outputType: OutputType = {
        if output.wasSet {
            return .StringsFiles
        }
        if auto.wasSet {
            return .Automatic
        }
        return .None
    }()
    
    let inputIbFilePath = input.value!

    let outputStringsFilesPaths: [String] = {
        switch outputType {
        case .StringsFiles:
            return output.value!
        case .Automatic:
            return StringsFilesSearch.sharedInstance.findAll(inputIbFilePath)
        case .None:
            print("Error! Missing output key '\(output.shortFlag!)' or '\(auto.shortFlag!)'.")
            exit(EX_USAGE)
        }
    }()
    
    guard NSFileManager.defaultManager().fileExistsAtPath(inputIbFilePath) else {
        print("Error! No file exists at input path '\(inputIbFilePath)'")
        exit(EX_NOINPUT)
    }
    
    for outputStringsFilePath in outputStringsFilesPaths {
        guard NSFileManager.defaultManager().fileExistsAtPath(outputStringsFilePath) else {
            print("Error! No file exists at output path '\(outputStringsFilePath)'.")
            exit(EX_CONFIG)
        }
    }
    
    let extractedStringsFilePath = inputIbFilePath + ".tmpstrings"
    
    guard IBToolCommander.sharedInstance.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputIbFilePath) else {
        print("Error! Could not extract strings from Storyboard or XIB at path '\(inputIbFilePath)'.")
        exit(EX_UNAVAILABLE)
    }
    
    for outputStringsFilePath in outputStringsFilesPaths {
        
        guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
            print("Error! Could not read strings file at path '\(outputStringsFilePath)'")
            exit(EX_CONFIG)
        }
        
        stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath)
        
    }
    
    do {
        try NSFileManager.defaultManager().removeItemAtPath(extractedStringsFilePath)
    } catch {
        print("Error! Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'")
        exit(EX_IOERR)
    }
    
    print("BartyCrouch: Successfully updated strings file(s) of Storyboard or XIB file.")
    
}

run()