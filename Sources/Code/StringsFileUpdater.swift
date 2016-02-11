//
//  StringsFileUpdater.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class StringsFileUpdater {
    
    private let path: String
    private var linesInFile: [String]

    
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
    public func incrementallyUpdateKeys(withStringsFileAtPath otherStringFilePath: String, addNewValuesAsEmpty: Bool = true) {
        
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)
            let linesInNewFile = newContentString.componentsSeparatedByCharactersInSet(.newlineCharacterSet())
            
            let oldTranslations = self.findTranslationsInLines(self.linesInFile)
            let newTranslations = self.findTranslationsInLines(linesInNewFile)
            
            let updatedTranslations: [(key: String, value: String, comment: String?)] = {
                
                var translations: [(key: String, value: String, comment: String?)] = []
                
                newTranslations.forEach { (key, value, comment) in
                 
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
    
    private func findTranslationsInLines(lines: [String]) -> [(key: String, value: String, comment: String?)] {
        
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
    
    private func stringFromTranslations(translations: [(key: String, value: String, comment: String?)]) -> String {
        
        var resultingString = "\n"
        
        let translationStrings = translations.map { (key, value, comment) -> String in
            let translationString: String = comment != nil ? "/*\(comment!)*/\n" : ""
            return translationString + "\"\(key)\" = \"\(value)\";"
        }
        
        resultingString += translationStrings.joinWithSeparator("\n\n")
        
        return resultingString + "\n"
    }
    
}
