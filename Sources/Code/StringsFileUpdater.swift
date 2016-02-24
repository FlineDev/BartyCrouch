//
//  StringsFileUpdater.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class StringsFileUpdater {
    
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
    public func incrementallyUpdateKeys(withStringsFileAtPath otherStringFilePath: String, addNewValuesAsEmpty: Bool = true, ignoreKeysWithBaseValueContainingAnyOfStrings: [String] = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]) {
        
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)
            let linesInNewFile = newContentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
            
            let oldTranslations = self.findTranslationsInLines(self.linesInFile)
            let newTranslations = self.findTranslationsInLines(linesInNewFile)
            
            let updatedTranslations: [(key: String, value: String, comment: String?)] = {
                
                var translations: [(key: String, value: String, comment: String?)] = []
                
                for (key, value, comment) in newTranslations {
                    
                    // skip keys marked for ignore
                    guard !value.containsAny(ofStrings: ignoreKeysWithBaseValueContainingAnyOfStrings) else {
                        continue
                    }
                    
                    let updatedValue: String = {
                        
                        let oldTranslation = oldTranslations.filter{ $0.0 == key }.first
                        if let existingValue = oldTranslation?.1 {
                            return existingValue
                        }
                        
                        if !addNewValuesAsEmpty {
                            return value
                        }
                        
                        return ""
                        
                    }()
                    
                    let updatedComment: String? = {
                        
                        let oldComment = oldTranslations.filter{ $0.0 == key }.first
                        if let existingComment = oldComment?.2 {
                            return existingComment
                        }
                        
                        return comment
                    }()
                    
                    let updatedTranslation = (key, updatedValue, updatedComment)
                    translations.append(updatedTranslation)
                    
                }
                
                return translations
                
            }()
            
            let newContentsOfFile = self.stringFromTranslations(updatedTranslations)
            
            try NSFileManager.defaultManager().removeItemAtPath(self.path)
            try newContentsOfFile.writeToFile(self.path, atomically: true, encoding: NSUTF8StringEncoding)
            
            let contentString = try String(contentsOfFile: self.path)
            self.linesInFile = contentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
            
        } catch {
            print((error as NSError).description)
        }
        
    }
    
    func findTranslationsInLines(lines: [String]) -> [(key: String, value: String, comment: String?)] {
        
        var foundTranslations: [(key: String, value: String, comment: String?)] = []
        var lastCommentLine: String?
        
        do {
            let commentLineRegex = try NSRegularExpression(pattern: "^\\s*/\\*(.*)\\*/\\s*$", options: .CaseInsensitive)
            let keyValueLineRegex = try NSRegularExpression(pattern: "^\\s*\"(.*)\"\\s*=\\s*\"(.*)\"\\s*;$", options: .CaseInsensitive)
            
            lines.forEach { line in
                if let commentLineMatch = commentLineRegex.firstMatchInString(line, options: .ReportCompletion, range: NSMakeRange(0, line.characters.count)) {
                    lastCommentLine = (line as NSString).substringWithRange(commentLineMatch.rangeAtIndex(1))
                }
                
                if let keyValueLineMatch = keyValueLineRegex.firstMatchInString(line, options: .ReportCompletion, range: NSMakeRange(0, line.characters.count)) {
                    
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
    
    func stringFromTranslations(translations: [(key: String, value: String, comment: String?)]) -> String {
        
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
            
            let fullRange = NSMakeRange(0, path.characters.count)
            
            
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