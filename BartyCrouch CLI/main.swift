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

let translate = StringOption(
    shortFlag: "t",
    longFlag: "translate",
    required: false,
    helpMessage: "Translate empty values using Microsoft Translator (id & secret needed): \"{ id: YOUR_ID }|{ secret: YOUR_SECRET }\"."
)

cli.addOptions(input, output, auto, translate)


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

enum ActionType {
    case IncrementalUpdate
    case Translate
}

func incrementalUpdate(inputFilePath: String, _ outputStringsFilesPaths: [String]) {
    let extractedStringsFilePath = inputFilePath + ".tmpstrings"
    
    guard IBToolCommander.sharedInstance.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputFilePath) else {
        print("Error! Could not extract strings from Storyboard or XIB at path '\(inputFilePath)'.")
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

func translate(credentials credentials: String, _ inputFilePath: String, _ outputStringsFilesPaths: [String]) {
    
    do {
        let translatorCredentialsRegex = try NSRegularExpression(pattern: "^\\{ id: (.+) \\}\\|\\{ secret: (.+) \\}$", options: .CaseInsensitive)
        
        let fullRange = NSMakeRange(0, credentials.characters.count)
        guard let match = translatorCredentialsRegex.matchesInString(credentials, options: .ReportProgress, range: fullRange).first else {
            print("Error! Couldn't read id and secret for Microsoft Translator. Please make sure you comply to the format '{ id: YOUR_ID }|{ secret: YOUR_SECRET }'.")
            return
        }
        
        let id = (credentials as NSString).substringWithRange(match.rangeAtIndex(1))
        let secret = (credentials as NSString).substringWithRange(match.rangeAtIndex(2))
        
        var overallTranslatedValuesCount = 0
        var filesWithTranslatedValuesCount = 0
        
        for outputStringsFilePath in outputStringsFilesPaths {
            
            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                print("Error! Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }
            
            let translationsCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret)
            
            if translationsCount > 0 {
                overallTranslatedValuesCount += translationsCount
                filesWithTranslatedValuesCount += 1
            }
            
        }
        
        print("BartyCrouch: Successfully translated \(overallTranslatedValuesCount) values in \(filesWithTranslatedValuesCount) files.")
        
    } catch {
        print("Error! Invalid credentials regular expression. Please report this issue at https://github.com/Flinesoft/BartyCrouch/issues.")
        exit(EX_SOFTWARE)
    }
    
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
    
    let actionType: ActionType = {
        if translate.wasSet {
            return .Translate
        }
        return .IncrementalUpdate
    }()
    
    let inputFilePath = input.value!

    let outputStringsFilesPaths: [String] = {
        switch outputType {
        case .StringsFiles:
            return output.value!
        case .Automatic:
            return StringsFilesSearch.sharedInstance.findAll(inputFilePath).filter { !$0.containsString(inputFilePath) }
        case .None:
            print("Error! Missing output key '\(output.shortFlag!)' or '\(auto.shortFlag!)'.")
            exit(EX_USAGE)
        }
    }()
    
    guard NSFileManager.defaultManager().fileExistsAtPath(inputFilePath) else {
        print("Error! No file exists at input path '\(inputFilePath)'")
        exit(EX_NOINPUT)
    }
    
    for outputStringsFilePath in outputStringsFilesPaths {
        guard NSFileManager.defaultManager().fileExistsAtPath(outputStringsFilePath) else {
            print("Error! No file exists at output path '\(outputStringsFilePath)'.")
            exit(EX_CONFIG)
        }
    }
    
    switch actionType {
    case .IncrementalUpdate:
        incrementalUpdate(inputFilePath, outputStringsFilesPaths)
    case .Translate:
        translate(credentials: translate.value!, inputFilePath, outputStringsFilesPaths)
    }
    
}


run()