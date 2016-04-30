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
    required: false,
    helpMessage: "Path to your source file to be used for translation."
)

let output = MultiStringOption(
    shortFlag: "o",
    longFlag: "output",
    required: false,
    helpMessage: "Paths to your strings files to be updated."
)

let search = StringOption(
    shortFlag: "s",
    longFlag: "search",
    required: false,
    helpMessage: "Automatically searches for all strings files for update/translation in given path."
)

let locale = StringOption(
    shortFlag: "l",
    longFlag: "locale",
    required: false,
    helpMessage: "Define source locale for automatic translation."
)

let except = MultiStringOption(
    shortFlag: "e",
    longFlag: "except",
    required: false,
    helpMessage: "Automatically finds all strings files for update except the ones specified."
)

let translate = StringOption(
    shortFlag: "t",
    longFlag: "translate",
    required: false,
    helpMessage: "Translates empty values using Microsoft Translator (id & secret needed): \"{ id: YOUR_ID }|{ secret: YOUR_SECRET }\"."
)

let force = BoolOption(
    shortFlag: "f",
    longFlag: "force",
    required: false,
    helpMessage: "Overrides existing translations / comments. Use carefully."
)

let verbose = BoolOption(
    shortFlag: "v",
    longFlag: "verbose",
    required: false,
    helpMessage: "Prints out more status information to the console."
)

let defaultToBase = BoolOption(
    shortFlag: "b",
    longFlag: "default-to-base",
    required: false,
    helpMessage: "Uses the values from Base localization when adding new keys."
)

cli.addOptions(input, output, search, locale, except, translate, force, verbose, defaultToBase)


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
    case Except
    case None
}

enum ActionType {
    case IncrementalUpdate
    case Translate
}

func incrementalUpdate(inputFilePath: String, _ outputStringsFilePaths: [String]) {
    let extractedStringsFilePath = inputFilePath + ".tmpstrings"
    
    guard IBToolCommander.sharedInstance.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputFilePath) else {
        print("Error! Could not extract strings from Storyboard or XIB at path '\(inputFilePath)'.")
        exit(EX_UNAVAILABLE)
    }
    
    for outputStringsFilePath in outputStringsFilePaths {
        
        guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
            print("Error! Could not read strings file at path '\(outputStringsFilePath)'")
            exit(EX_CONFIG)
        }
        
        stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath, addNewValuesAsEmpty: !defaultToBase.value, force: force.value)
        
        if verbose.value {
            print("Incrementally updated keys of file '\(outputStringsFilePath)'.")
        }
        
    }
    
    do {
        try NSFileManager.defaultManager().removeItemAtPath(extractedStringsFilePath)
    } catch {
        print("Error! Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'")
        exit(EX_IOERR)
    }
    
    print("BartyCrouch: Successfully updated strings file(s) of Storyboard or XIB file.")
}

func translate(credentials credentials: String, _ inputFilePath: String, _ outputStringsFilePaths: [String]) {
    
    do {
        let translatorCredentialsRegex = try NSRegularExpression(pattern: "^\\{ id: (.+) \\}\\|\\{ secret: (.+) \\}$", options: .CaseInsensitive)
        
        let fullRange = NSMakeRange(0, credentials.utf16.count)
        guard let match = translatorCredentialsRegex.matchesInString(credentials, options: .ReportProgress, range: fullRange).first else {
            print("Error! Couldn't read id and secret for Microsoft Translator. Please make sure you comply to the format '{ id: YOUR_ID }|{ secret: YOUR_SECRET }'.")
            return
        }
        
        let id = (credentials as NSString).substringWithRange(match.rangeAtIndex(1))
        let secret = (credentials as NSString).substringWithRange(match.rangeAtIndex(2))
        
        var overallTranslatedValuesCount = 0
        var filesWithTranslatedValuesCount = 0
        
        for outputStringsFilePath in outputStringsFilePaths {
            
            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                print("Error! Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }
            
            let translationsCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret, force: force.value)
            
            if verbose.value {
                print("Translated file '\(outputStringsFilePath)' with \(translationsCount) changes.")
            }
            
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
        if except.wasSet {
            return .Except
        }
        if search.wasSet {
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
    
    let inputFilePaths: [String] = {
        if let inputFilePath = input.value {
            return [inputFilePath]
        } else if outputType == .Automatic {
            
            guard let searchPath = search.value else {
                print("Error! Search path is missing.")
                exit(EX_USAGE)
            }
            
            let localeString: String = {
                switch actionType {
                case .Translate:
                    
                    guard let localeString = locale.value else {
                        print("Error! Automatic translations can only be done with a locale set.")
                        exit(EX_USAGE)
                    }
                    
                    return localeString
                    
                case .IncrementalUpdate:
                    
                    if locale.value != nil {
                        return locale.value!
                    } else {
                        return "Base"
                    }
                    
                }
            }()
            
            switch actionType {
            case .Translate:
                return StringsFilesSearch.sharedInstance.findAllStringsFiles(searchPath, withLocale: localeString)
            case .IncrementalUpdate:
                return StringsFilesSearch.sharedInstance.findAllIBFiles(searchPath, withLocale: localeString)
            }
            
        } else {
            print("Error! Missing input path(s).")
            exit(EX_USAGE)
        }
    }()
    
    guard inputFilePaths.count > 0 else {
        print("Error! No input files found.")
        exit(EX_USAGE)
    }
    
    for inputFilePath in inputFilePaths {
        
        let outputStringsFilePaths: [String] = {
            switch outputType {
            case .StringsFiles:
                if let stringsFiles = output.value {
                    // check if output style is locales-only, e.g. `-o en de zh-Hans pt-BR` - convert to full paths if so
                    do {
                        let localeRegex = try NSRegularExpression(pattern: "\\A\\w{2}(-\\w{2,4})?\\z", options: .CaseInsensitive)
                        let locales = stringsFiles.filter { localeRegex.matchesInString($0, options: .ReportCompletion, range: NSMakeRange(0, $0.utf16.count)).count > 0 }
                        if locales.count == stringsFiles.count {
                            let lprojLocales = locales.map { "\($0).lproj" }
                            return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0.containsAny(ofStrings: lprojLocales) }
                        }
                    } catch {
                        print("Error! Couldn't init locale regex. Please report this issue on https://github.com/Flinesoft/BartyCrouch/issues.")
                    }
                }
                return output.value!
            case .Automatic:
                return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0 != inputFilePath }
            case .Except:
                return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0 != inputFilePath && !except.value!.contains($0) }
            case .None:
                print("Error! Missing output key '\(output.shortFlag!)' or '\(search.shortFlag!)'.")
                exit(EX_USAGE)
            }
        }()
        
        guard NSFileManager.defaultManager().fileExistsAtPath(inputFilePath) else {
            print("Error! No file exists at input path '\(inputFilePath)'")
            exit(EX_NOINPUT)
        }
        
        for outputStringsFilePath in outputStringsFilePaths {
            guard NSFileManager.defaultManager().fileExistsAtPath(outputStringsFilePath) else {
                print("Error! No file exists at output path '\(outputStringsFilePath)'.")
                exit(EX_CONFIG)
            }
        }
        
        switch actionType {
        case .IncrementalUpdate:
            incrementalUpdate(inputFilePath, outputStringsFilePaths)
        case .Translate:
            translate(credentials: translate.value!, inputFilePath, outputStringsFilePaths)
        }

    }
    
}


run()