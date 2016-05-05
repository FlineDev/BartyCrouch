//
//  StringsFilesSearch.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 14.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Searchs for `.strings` files given a base internationalized Storyboard.
public class StringsFilesSearch {
    
    // MARK: - Stored Class Properties
    
    public static let sharedInstance = StringsFilesSearch()
    
    
    // MARK: - Instance Methods
    
    public func findAllIBFiles(baseDirectoryPath: String, withLocale locale: String = "Base") -> [String] {
        do {
            let ibFileRegex = try NSRegularExpression(pattern: ".*\\/\(locale).lproj.*\\.(storyboard|xib)\\z", options: .CaseInsensitive)
            return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: ibFileRegex)
        } catch {
            return []
        }
    }
    
    public func findAllStringsFiles(baseDirectoryPath: String, withLocale locale: String) -> [String] {
        do {
            let stringsFileRegex = try NSRegularExpression(pattern: ".*\\/\(locale).lproj.*\\.strings\\z", options: .CaseInsensitive)
            return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: stringsFileRegex)
        } catch {
            return []
        }
    }
    
    public func findAllStringsFiles(baseDirectoryPath: String, withFileName fileName: String) -> [String] {
        do {
            let stringsFileRegex = try NSRegularExpression(pattern: ".*\\.lproj/\(fileName)\\.strings\\z", options: .CaseInsensitive)
            return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: stringsFileRegex)
        } catch {
            return []
        }
    }
    
    public func findAllLocalesForStringsFile(sourceFilePath: String) -> [String] {
        var pathComponents = sourceFilePath.componentsSeparatedByString("/")
        let storyboardName: String = {
            var fileNameComponents = pathComponents.last!.componentsSeparatedByString(".")
            fileNameComponents.removeLast()
            return fileNameComponents.joinWithSeparator(".")
        }()
        
        pathComponents.removeLast() // Remove last path component from folder/base.lproj/some.storyboard
        pathComponents.removeLast() // Remove last path component from folder/base.lproj
        
        let folderWithLanguageSubfoldersPath = pathComponents.joinWithSeparator("/")
        
        do {
            let filesInDirectory = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderWithLanguageSubfoldersPath)
            let languageDirPaths = filesInDirectory.filter { $0.rangeOfString(".lproj") != nil && $0 != "Base.lproj" }
            return languageDirPaths.map { folderWithLanguageSubfoldersPath + "/" + $0 + "/" + storyboardName + ".strings" }
        } catch {
            return []
        }
    }
    
    func findAllFilePaths(inDirectoryPath baseDirectoryPath: String, matching regularExpression: NSRegularExpression) -> [String] {
        do {
            let pathsToIgnore = [".git/", "Carthage/", "build/", "docs/"]
            let allFilePaths = try NSFileManager.defaultManager().subpathsOfDirectoryAtPath(baseDirectoryPath).filter { !$0.containsAny(ofStrings: pathsToIgnore) }
            let ibFilePaths = allFilePaths.filter { regularExpression.matchesInString($0, options: .ReportCompletion, range: NSMakeRange(0, $0.utf16.count)).count > 0 }
            return ibFilePaths.map { baseDirectoryPath + "/" + $0 }
        } catch {
            return []
        }
    }

}
