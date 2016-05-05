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

let interfacesPath = StringOption(
    shortFlag: "i",
    longFlag: "interfaces-path",
    required: false,
    helpMessage: "Set the base path to recursively search within for Interface Builder files (.xib, .storyboard)."
)

let codePath = StringOption(
    shortFlag: "c",
    longFlag: "code-path",
    required: false,
    helpMessage: "Set the base path to recursively search within for code files (.h, .m, .swift)."
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

let code = StringOption(
    shortFlag: "c",
    longFlag: "code",
    required: false,
    helpMessage: "Also incrementally updates `Localizable.strings` in the specified path with `NSLocalizedString` macros from code."
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

cli.addOptions(input, output, search, locale, except, translate, code, force, verbose, defaultToBase)


// Parse input data or exit with usage instructions

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}


// Do requested action(s)

func run() {

    let outputType: CommandLineActor.OutputType = {
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
    
    let actionType: CommandLineActor.ActionType = {
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
        
        let commandLineActor = CommandLineActor(verbose: verbose.value, force: force.value)
        
        switch actionType {
        case .IncrementalUpdate:
            commandLineActor.incrementalUpdate(inputFilePath, outputStringsFilePaths, defaultToBase: defaultToBase.value)
        case .Translate:
            commandLineActor.translate(credentials: translate.value!, inputFilePath, outputStringsFilePaths)
        }

    }
    
}


run()