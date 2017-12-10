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
    // MARK: - Stored Type Properties
    public static let shared = StringsFilesSearch()

    // MARK: - Instance Methods
    public func findAllIBFiles(within baseDirectoryPath: String, withLocale locale: String = "Base") -> [String] {
        // swiftlint:disable:next force_try
        let ibFileRegex = try! NSRegularExpression(pattern: ".*\\/\(locale).lproj.*\\.(storyboard|xib)\\z", options: .caseInsensitive)
        return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: ibFileRegex)
    }

    public func findAllStringsFiles(within baseDirectoryPath: String, withLocale locale: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: ".*\\/\(locale).lproj.*\\.strings\\z", options: .caseInsensitive)
        return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: stringsFileRegex)
    }

    public func findAllStringsFiles(within baseDirectoryPath: String, withFileName fileName: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: ".*\\.lproj/\(fileName)\\.strings\\z", options: .caseInsensitive)
        return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: stringsFileRegex)
    }

    public func findAllStringsFiles(within baseDirectoryPath: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: ".*\\.lproj.*\\.strings\\z", options: .caseInsensitive)
        let stringFiles = self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: stringsFileRegex)

        let ibFileNames = self.findAllIBFiles(within: baseDirectoryPath).map { extractFileName(from: $0) }

        return stringFiles.filter { stringFilePath in
            // swiftlint:disable:next if_as_guard
            for ibFileName in ibFileNames {
                if stringFilePath.range(of: ibFileName) != nil {
                    return false
                }
            }

            return true
        }
    }

    public func findAllLocalesForStringsFile(sourceFilePath: String) -> [String] {
        let storyboardName = extractFileName(from: sourceFilePath)

        var pathComponents = sourceFilePath.components(separatedBy: "/")
        pathComponents.removeLast() // Remove last path component from folder/base.lproj/some.storyboard
        pathComponents.removeLast() // Remove last path component from folder/base.lproj

        let folderWithLanguageSubfoldersPath = pathComponents.joined(separator: "/")

        do {
            let filesInDirectory = try FileManager.default.contentsOfDirectory(atPath: folderWithLanguageSubfoldersPath)
            let languageDirPaths = filesInDirectory.filter { $0.range(of: ".lproj") != nil && $0 != "Base.lproj" }
            return languageDirPaths.map { [folderWithLanguageSubfoldersPath, $0, "\(storyboardName).strings"].joined(separator: "/") }
        } catch {
            return []
        }
    }

    func findAllFilePaths(inDirectoryPath baseDirectoryPath: String, matching regularExpression: NSRegularExpression) -> [String] {
        do {
            let pathsToIgnore = [".git/", "Carthage/", "Pods/", "build/", "docs/"]
            let allFilePaths = try FileManager.default.subpathsOfDirectory(atPath: baseDirectoryPath).filter { !$0.containsAny(of: pathsToIgnore) }
            let ibFilePaths = allFilePaths.filter { filePath in
                return !regularExpression.matches(in: filePath, options: .reportCompletion, range: filePath.fullRange).isEmpty
            }

            return ibFilePaths.map { baseDirectoryPath + "/" + $0 }
        } catch {
            return []
        }
    }

    private func extractFileName(from filePath: String) -> String {
        let pathComponents = filePath.components(separatedBy: "/")
        var fileNameComponents = pathComponents.last!.components(separatedBy: ".")
        fileNameComponents.removeLast()
        return fileNameComponents.joined(separator: ".")
    }
}
