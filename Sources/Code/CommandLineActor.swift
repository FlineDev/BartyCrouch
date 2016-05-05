//
//  CommandLineActor.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public enum CommandLineAction {
    case Interfaces()
    case Code()
    case Translate()
}

public class CommandLineActor {
    
    // MARK: - Instance Methods
    
    public func act(commonOptions: CommandLineParser.CommonOptions, subCommandOptions: CommandLineParser.SubCommandOptions) {
        
        guard let path = commonOptions.path.value else {
            self.printError("Path argument `-p` is missing.")
            exit(EX_USAGE)
        }
        
        let override = commonOptions.override.value
        let verbose = commonOptions.verbose.value
        
        
        switch subCommandOptions {
        case let .CodeOptions(localizableOption, defaultToBaseOption, additiveOption):
            guard let localizable = localizableOption.value else {
                self.printError("Localizable argument `-l` is missing.")
                exit(EX_USAGE)
            }
            
            self.actOnCode(path: path, override: override, verbose: verbose, localizable: localizable, defaultToBase: defaultToBaseOption.value, additive: additiveOption.value)
            
        case let .InterfacesOptions(defaultToBaseOption):
            self.actOnInterfaces(path: path, override: override, verbose: verbose, defaultToBase: defaultToBaseOption.value)
            
        case let .TranslateOptions(idOption, secretOption):
            guard let id = idOption.value else {
                self.printError("Microsoft Translator API credential 'id' missing. Specify via option `-i`.")
                exit(EX_USAGE)
            }
            
            guard let secret = secretOption.value else {
                self.printError("Microsoft Translator API credential 'secret' missing. Specify via option `-s`.")
                exit(EX_USAGE)
            }
            
            self.actOnTranslate(path: path, override: override, verbose: verbose, id: id, secret: secret)
        }
        
    }
    
    private func actOnCode(path path: String, override: Bool, verbose: Bool, localizable: String, defaultToBase: Bool, additive: Bool) {
    
        // TODO: not yet implemented
        
    }
    
    private func actOnInterfaces(path path: String, override: Bool, verbose: Bool, defaultToBase: Bool) {
        
        // TODO: not yet implemented
        
    }
    
    private func actOnTranslate(path path: String, override: Bool, verbose: Bool, id: String, secret: String) {
        
        // TODO: not yet implemented
        
    }
    
    private func incrementalUpdate(inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool, defaultToBase: Bool) {
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
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath, addNewValuesAsEmpty: !defaultToBase, override: override)
            
            if verbose {
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
    
    private func translate(credentials credentials: String, _ inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool) {
        
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
                
                let translationsCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret, override: override)
                
                if verbose {
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
    

    // MARK: - Helper Methods
    
    private func printError(message: String) {
        print("Error! \(message)")
    }
    
}


//
//        let inputFilePaths: [String] = {
//            if let inputFilePath = input.value {
//                return [inputFilePath]
//            } else if outputType == .Automatic {
//
//                guard let searchPath = search.value else {
//                    print("Error! Search path is missing.")
//                    exit(EX_USAGE)
//                }
//
//                let localeString: String = {
//                    switch actionType {
//                    case .Translate:
//
//                        guard let localeString = locale.value else {
//                            print("Error! Automatic translations can only be done with a locale set.")
//                            exit(EX_USAGE)
//                        }
//
//                        return localeString
//
//                    case .IncrementalUpdate:
//
//                        if locale.value != nil {
//                            return locale.value!
//                        } else {
//                            return "Base"
//                        }
//
//                    }
//                }()
//
//                switch actionType {
//                case .Translate:
//                    return StringsFilesSearch.sharedInstance.findAllStringsFiles(searchPath, withLocale: localeString)
//                case .IncrementalUpdate:
//                    return StringsFilesSearch.sharedInstance.findAllIBFiles(searchPath, withLocale: localeString)
//                }
//
//            } else {
//                print("Error! Missing input path(s).")
//                exit(EX_USAGE)
//            }
//        }()
//
//        guard inputFilePaths.count > 0 else {
//            print("Error! No input files found.")
//            exit(EX_USAGE)
//        }
//
//        for inputFilePath in inputFilePaths {
//
//            let outputStringsFilePaths: [String] = {
//                switch outputType {
//                case .StringsFiles:
//                    if let stringsFiles = output.value {
//                        // check if output style is locales-only, e.g. `-o en de zh-Hans pt-BR` - convert to full paths if so
//                        do {
//                            let localeRegex = try NSRegularExpression(pattern: "\\A\\w{2}(-\\w{2,4})?\\z", options: .CaseInsensitive)
//                            let locales = stringsFiles.filter { localeRegex.matchesInString($0, options: .ReportCompletion, range: NSMakeRange(0, $0.utf16.count)).count > 0 }
//                            if locales.count == stringsFiles.count {
//                                let lprojLocales = locales.map { "\($0).lproj" }
//                                return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0.containsAny(ofStrings: lprojLocales) }
//                            }
//                        } catch {
//                            print("Error! Couldn't init locale regex. Please report this issue on https://github.com/Flinesoft/BartyCrouch/issues.")
//                        }
//                    }
//                    return output.value!
//                case .Automatic:
//                    return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0 != inputFilePath }
//                case .Except:
//                    return StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(inputFilePath).filter { $0 != inputFilePath && !except.value!.contains($0) }
//                case .None:
//                    print("Error! Missing output key '\(output.shortFlag!)' or '\(search.shortFlag!)'.")
//                    exit(EX_USAGE)
//                }
//            }()
//
//            guard NSFileManager.defaultManager().fileExistsAtPath(inputFilePath) else {
//                print("Error! No file exists at input path '\(inputFilePath)'")
//                exit(EX_NOINPUT)
//            }
//
//            for outputStringsFilePath in outputStringsFilePaths {
//                guard NSFileManager.defaultManager().fileExistsAtPath(outputStringsFilePath) else {
//                    print("Error! No file exists at output path '\(outputStringsFilePath)'.")
//                    exit(EX_CONFIG)
//                }
//            }
//
//            let commandLineActor = CommandLineActor(verbose: verbose.value, force: force.value)
//
//            switch actionType {
//            case .IncrementalUpdate:
//                commandLineActor.incrementalUpdate(inputFilePath, outputStringsFilePaths, defaultToBase: defaultToBase.value)
//            case .Translate:
//                commandLineActor.translate(credentials: translate.value!, inputFilePath, outputStringsFilePaths)
//            }
//
//        }
