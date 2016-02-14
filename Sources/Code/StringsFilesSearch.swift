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
    
    public func findAll(baseStoryboardPath: String) -> [String] {
        var pathComponents = baseStoryboardPath.componentsSeparatedByString("/")
        let storyboardName: String = {
            var storyboardNameComponents = pathComponents.last!.componentsSeparatedByString(".")
            storyboardNameComponents.removeLast()
            return storyboardNameComponents.joinWithSeparator(".")
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

}
