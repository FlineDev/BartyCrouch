//
//  CommandLineActor.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

class CommandLineActor: NSObject {

    // MARK: - Sub Types
    
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
    
    
    // MARK: - Stored Instance Properties
    
    let verbose: Bool
    let force: Bool

    
    // MARK: - Initializers
    
    init(verbose: Bool, force: Bool) {
        self.verbose = verbose
        self.force = force
        
        super.init()
    }

    
    // MARK: - Instance Methods
    
    func incrementalUpdate(inputFilePath: String, _ outputStringsFilePaths: [String], defaultToBase: Bool) {
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
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath, addNewValuesAsEmpty: !defaultToBase, force: self.force)
            
            if self.verbose {
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
                
                let translationsCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret, force: self.force)
                
                if self.verbose {
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
    

    
}

