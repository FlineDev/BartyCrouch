//
//  StringsFileUpdater.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class StringsFileUpdater {
    
    typealias TranslationEntry = (key: String, value: String, comment: String?)
    
    let path: String
    var linesInFile: [String]

    
    // MARK: - Initializers
    
    public init?(path: String) {
        self.path = path
        do {
            let contentString = try String(contentsOfFile: path)
            self.linesInFile = contentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
        } catch {
            print((error as NSError).description)
            self.linesInFile = []
            return nil
        }
    }
    
    /// Updates the keys of this instances strings file with those of the given strings file.
    /// Note that this will add new keys, remove not-existing keys but won't touch any existing ones.
    public func incrementallyUpdateKeys(withStringsFileAtPath otherStringFilePath: String, addNewValuesAsEmpty: Bool, ignoreKeysWithBaseValueContainingAnyOfStrings: [String] = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"], force: Bool = false, updateCommentWithBase: Bool = true) {
        
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)
            let linesInNewFile = newContentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
            
            let oldTranslations = self.findTranslationsInLines(self.linesInFile)
            let newTranslations = self.findTranslationsInLines(linesInNewFile)
            
            let updatedTranslations: [TranslationEntry] = {
                
                var translations: [TranslationEntry] = []
                
                for (key, newValue, newComment) in newTranslations {
                    
                    // skip keys marked for ignore
                    guard !newValue.containsAny(ofStrings: ignoreKeysWithBaseValueContainingAnyOfStrings) else {
                        continue
                    }
                    
                    let oldTranslation = oldTranslations.filter{ $0.0 == key }.first
                    
                    // get value from default comment structure if possible
                    let oldBaseValue: String? = {
                        if let oldComment = oldTranslation?.2 {
                            if let foundMatch = self.defaultCommentStructureMatches(inString: oldComment) {
                                return (oldComment as NSString).substringWithRange(foundMatch.rangeAtIndex(1))
                            }
                        }
                        
                        return nil
                    }()

                    
                    let updatedComment: String? = {
                        
                        guard let oldComment = oldTranslation?.2 else {
                            // add new comment if none existed before
                            return newComment
                        }
                        
                        guard let newComment = newComment else {
                            // keep old comment if no new comment exists
                            return oldComment
                        }
                        
                        if force {
                            // override with comment in force update mode
                            return newComment
                        }
                        
                        if updateCommentWithBase && self.defaultCommentStructureMatches(inString: oldComment) != nil {
                            // update
                            return newComment
                        } else {
                            return oldComment
                        }
                    }()

                    
                    let updatedValue: String = {
                        
                        let oldTranslation = oldTranslations.filter{ $0.0 == key }.first
                        
                        guard let oldValue = oldTranslation?.1 else {
                            if addNewValuesAsEmpty {
                                // add new key with empty value
                                return ""
                            } else {
                                // add new key with Base value
                                return newValue
                            }
                        }
                        
                        if force {
                            // override with new value in force update mode
                            return newValue
                        }
                        
                        if let oldBaseValue = oldBaseValue {
                            if oldBaseValue == oldValue {
                                // update base value
                                return newValue
                            }
                        }
                        
                        // keep existing translation
                        return oldValue
                        
                    }()
                    
                    
                    let updatedTranslation = (key, updatedValue, updatedComment)
                    translations.append(updatedTranslation)
                    
                }
                
                return translations
                
            }()
            
            self.rewriteFileWithTranslations(updatedTranslations)
            
        } catch {
            print((error as NSError).description)
        }
        
    }
    
    private func defaultCommentStructureMatches(inString string: String) -> NSTextCheckingResult? {
        do {
            let defaultCommentStructureRegex = try NSRegularExpression(pattern: "\\A Class = \".*\"; .* = \"(.*)\"; ObjectID = \".*\"; \\z", options: .CaseInsensitive)
            return defaultCommentStructureRegex.matchesInString(string, options: .ReportCompletion, range: NSMakeRange(0, string.utf16.count)).first
        } catch {
            return nil
        }
    }
    
    /// Rewrites file with specified translations and reloads lines from new file.
    func rewriteFileWithTranslations(translations: [TranslationEntry]) {
        
        do {
            let newContentsOfFile = self.stringFromTranslations(translations)
            
            try NSFileManager.defaultManager().removeItemAtPath(self.path)
            try newContentsOfFile.writeToFile(self.path, atomically: true, encoding: NSUTF8StringEncoding)
            
            let contentString = try String(contentsOfFile: self.path)
            self.linesInFile = contentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())

        } catch {
            print((error as NSError).description)
        }
        
    }
    
    
    /// Translates all empty values of this instances strings file using the Microsoft Translator API.
    /// Note that this will only work for languages supported by the Microsoft Translator API and Polyglot.
    /// See here for a full list: https://www.microsoft.com/en-us/translator/faq.aspx
    ///
    /// Note that you need to register for the Microsoft Translator API here:
    /// https://datamarket.azure.com/dataset/bing/microsofttranslator
    ///
    /// Then you can register your client to retrieve the client id & secret here:
    /// https://datamarket.azure.com/developer/applications
    /// 
    /// - Parameters:
    ///   - usingValuesFromStringsFile:     The path to the strings file to use as source language for the translation.
    ///   - clientId:                       The Microsoft Translator API Client ID.
    ///   - clientSecret:                   The Microsoft Translator API Client Secret.
    /// - Returns: The number of values translated successfully.
    public func translateEmptyValues(usingValuesFromStringsFile sourceStringsFilePath: String, clientId: String, clientSecret: String, force: Bool = false) -> Int {
        
        guard let (sourceLanguage, sourceRegion) = self.extractLocale(fromPath: sourceStringsFilePath) else {
            print("Error! Could not obtain source locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
            return 0
        }
        
        guard let (targetLanguage, targetRegion) = self.extractLocale(fromPath: self.path) else {
            print("Error! Could not obtain target locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
            return 0
        }
        
        guard let sourceTranslatorLanguage = Language.languageForLocale(languageCode: sourceLanguage, region: sourceRegion) else {
            let locale = sourceRegion != nil ? "\(sourceLanguage)-\(sourceRegion!)" : sourceLanguage
            print("Warning! Automatic translation from the locale '\(locale)' is not supported.")
            return 0
        }
        
        guard let targetTranslatorLanguage = Language.languageForLocale(languageCode: targetLanguage, region: targetRegion) else {
            let locale = targetRegion != nil ? "\(targetLanguage)-\(targetRegion!)" : targetLanguage
            print("Warning! Automatic translation to the locale '\(locale)' is not supported.")
            return 0
        }
        
        do {
            let sourceContentString = try String(contentsOfFile: sourceStringsFilePath)
            let linesInSourceFile = sourceContentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
            
            let translator = Polyglot(clientId: clientId, clientSecret: clientSecret)
            
            translator.fromLanguage = sourceTranslatorLanguage
            translator.toLanguage = targetTranslatorLanguage
            
            var translatedValuesCount = 0
            var awaitingTranslationRequestCount = 0
            
            let sourceTranslations = self.findTranslationsInLines(linesInSourceFile)
            let existingTargetTranslations = self.findTranslationsInLines(self.linesInFile)
            var updatedTargetTranslations: [TranslationEntry] = []
            
            for sourceTranslation in sourceTranslations {
                
                let (sourceKey, sourceValue, sourceComment) = sourceTranslation
                var targetTranslationOptional = existingTargetTranslations.filter{ $0.0 == sourceKey }.first
                
                if targetTranslationOptional == nil {
                    targetTranslationOptional = (sourceKey, "", sourceComment)
                }
                
                guard let targetTranslation = targetTranslationOptional else {
                    NSException(name: "targetTranslation was nil when not expected", reason: nil, userInfo: nil).raise()
                    exit(EXIT_FAILURE)
                }
                
                let (key, value, comment) = targetTranslation
                
                guard value.isEmpty || force else {
                    updatedTargetTranslations.append(targetTranslation)
                    continue // skip already translated values
                }
                
                guard !sourceValue.isEmpty else {
                    print("Warning! Value for key '\(key)' in source translations is empty.")
                    continue
                }
                
                awaitingTranslationRequestCount += 1
                let updatedTargetTranslationIndex = updatedTargetTranslations.count
                updatedTargetTranslations.append(targetTranslation)
                
                translator.translate(sourceValue, callback: { translatedValue in
                    if !translatedValue.isEmpty {
                        updatedTargetTranslations[updatedTargetTranslationIndex] = (key, translatedValue, comment)
                        translatedValuesCount += 1
                    }
                    
                    awaitingTranslationRequestCount -= 1
                })
            }
            
            // wait for callbacks of all asynchronous translation calls -- will wait forever if any callback doesn't fire
            while awaitingTranslationRequestCount > 0 {
                // noop
            }

            if translatedValuesCount > 0 {
                self.rewriteFileWithTranslations(updatedTargetTranslations)
            }
            
            return translatedValuesCount
        } catch {
            print((error as NSError).description)
            return 0
        }

    }
    
    /// - Returns: An array containing all found translations as tuples in the format `(key, value, comment?)`.
    func findTranslationsInLines(lines: [String]) -> [TranslationEntry] {
        
        var foundTranslations: [TranslationEntry] = []
        var lastCommentLine: String?
        
        do {
            let commentLineRegex = try NSRegularExpression(pattern: "^\\s*/\\*(.*)\\*/\\s*$", options: .CaseInsensitive)
            let keyValueLineRegex = try NSRegularExpression(pattern: "^\\s*\"(.*)\"\\s*=\\s*\"(.*)\"\\s*;$", options: .CaseInsensitive)
            
            lines.forEach { line in
                if let commentLineMatch = commentLineRegex.firstMatchInString(line, options: .ReportCompletion, range: NSMakeRange(0, line.utf16.count)) {
                    lastCommentLine = (line as NSString).substringWithRange(commentLineMatch.rangeAtIndex(1))
                }
                
                if let keyValueLineMatch = keyValueLineRegex.firstMatchInString(line, options: .ReportCompletion, range: NSMakeRange(0, line.utf16.count)) {
                    
                    let key = (line as NSString).substringWithRange(keyValueLineMatch.rangeAtIndex(1))
                    let value = (line as NSString).substringWithRange(keyValueLineMatch.rangeAtIndex(2))
                    
                    let foundTranslation = (key, value, lastCommentLine)
                    foundTranslations.append(foundTranslation)
                    
                    lastCommentLine = nil
                }
            }
            
        } catch {
            
            print("Finding translations in lines failed")
            
        }
        
        return foundTranslations
        
    }
    
    func stringFromTranslations(translations: [TranslationEntry]) -> String {
        
        var resultingString = "\n"
        
        let translationStrings = translations.map { (key, value, comment) -> String in
            let translationString: String = comment != nil ? "/*\(comment!)*/\n" : ""
            return translationString + "\"\(key)\" = \"\(value)\";"
        }
        
        resultingString += translationStrings.joinWithSeparator("\n\n")
        
        return resultingString + "\n"
    }
    
    
    /// Extracts locale from a path containing substring `{language}-{region}.lproj` or `{language}.lproj`.
    ///
    /// - Parameters:
    ///   - fromPath: The path to extract the locale from.
    /// - Returns: A tuple containing the extracted language and region (if any) or nil if couldn't find locale in path.
    func extractLocale(fromPath path: String) -> (language: String, region: String?)? {
        
        do {
            // Initialize regular expressions
            let languageRegex = try NSRegularExpression(pattern: "(\\w{2})-{0,1}\\w*\\.lproj", options: .CaseInsensitive)
            let regionRegex = try NSRegularExpression(pattern: "\\w{2}-(\\w+)\\.lproj", options: .CaseInsensitive)
            
            let fullRange = NSMakeRange(0, path.utf16.count)
            
            
            // Get language from path
            guard let languageMatch = languageRegex.matchesInString(path, options: .ReportCompletion, range: fullRange).last else {
                return nil
            }
            let language = (path as NSString).substringWithRange(languageMatch.rangeAtIndex(1))
            
            
            // Get region from path if existent
            var region: String? = nil
            
            if let regionMatch = regionRegex.matchesInString(path, options: .ReportCompletion, range: fullRange).last {
                region = (path as NSString).substringWithRange(regionMatch.rangeAtIndex(1))
            }
            
            return (language, region)
            
        } catch {
            print("Error! Could not instantiate regular expressions. Please report this issue on https://github.com/Flinesoft/BartyCrouch/issues.")
            return nil
        }
        
    }

    
}


// MARK: - String Extension

extension String {
    
    func containsAny(ofStrings substrings: [String]) -> Bool {
        for substring in substrings {
            if self.containsString(substring) {
                return true
            }
        }
        return false
    }
    
}