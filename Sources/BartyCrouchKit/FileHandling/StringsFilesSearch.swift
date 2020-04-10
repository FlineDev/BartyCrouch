import Foundation

// NOTE:
// This file was not refactored as part of the work/big-refactoring branch for version 4.0 to prevent unexpected behavior changes.
// A rewrite after writing extensive tests for the expected behavior could improve readability, extensibility and performance.

/// Searchs for `.strings` files given a base internationalized Storyboard.
public final class StringsFilesSearch: FilesSearchable {
    // MARK: - Stored Type Properties
    public static let shared = StringsFilesSearch()

    private static let blacklistedStringFileNames: Set<String> = ["InfoPlist.strings"]

    // MARK: - Instance Methods
    public func findAllIBFiles(within baseDirectoryPath: String, withLocale locale: String = "Base") -> [String] {
        // swiftlint:disable:next force_try
        let ibFileRegex = try! NSRegularExpression(pattern: "^(.*\\/)?\(locale).lproj.*\\.(storyboard|xib)\\z", options: .caseInsensitive)
        return self.findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: ibFileRegex)
    }

    public func findAllStringsFiles(within baseDirectoryPath: String, withLocale locale: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: "^(.*\\/)?\(locale).lproj.*\\.strings\\z", options: .caseInsensitive)
        return self.findAllFilePaths(
            inDirectoryPath: baseDirectoryPath,
            matching: stringsFileRegex,
            ignoreSuffixes: StringsFilesSearch.blacklistedStringFileNames
        )
    }

    public func findAllStringsFiles(within baseDirectoryPath: String, withFileName fileName: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: ".*\\.lproj/\(fileName)\\.strings\\z", options: .caseInsensitive)
        return self.findAllFilePaths(
            inDirectoryPath: baseDirectoryPath,
            matching: stringsFileRegex,
            ignoreSuffixes: StringsFilesSearch.blacklistedStringFileNames
        )
    }

    public func findAllStringsFiles(within baseDirectoryPath: String) -> [String] {
        // swiftlint:disable:next force_try
        let stringsFileRegex = try! NSRegularExpression(pattern: ".*\\.lproj/.+\\.strings\\z", options: .caseInsensitive)
        return self.findAllFilePaths(
            inDirectoryPath: baseDirectoryPath,
            matching: stringsFileRegex,
            ignoreSuffixes: StringsFilesSearch.blacklistedStringFileNames
        )
    }

    public func findAllLocalesForStringsFile(sourceFilePath: String) -> [String] {
        var pathComponents = sourceFilePath.components(separatedBy: "/")
        let storyboardName: String = {
            var fileNameComponents = pathComponents.last!.components(separatedBy: ".")
            fileNameComponents.removeLast()
            return fileNameComponents.joined(separator: ".")
        }()

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
}
