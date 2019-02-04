//
//  FilesSearchable.swift
//  BartyCrouchKit
//
//  Created by Cihat Gündüz on 24.01.19.
//

import Foundation

protocol FilesSearchable {
    func findAllFilePaths(inDirectoryPath baseDirectoryPath: String, matching regularExpression: NSRegularExpression) -> [String]
}

extension FilesSearchable {
    func findAllFilePaths(inDirectoryPath baseDirectoryPath: String, matching regularExpression: NSRegularExpression) -> [String] {
        let baseDirectoryURL = URL(fileURLWithPath: baseDirectoryPath)
        guard let enumerator = FileManager.default.enumerator(at: baseDirectoryURL, includingPropertiesForKeys: nil) else { return [] }

        var filePaths = [String]()
        let dirsToIgnore = Set([".git", "Carthage", "Pods", "build", "docs"])
        let baseDirectoryAbsolutePath = baseDirectoryURL.path

        for case let url as URL in enumerator {
            if dirsToIgnore.contains(url.lastPathComponent) {
                enumerator.skipDescendants()
                continue
            }

            let absolutePath = url.path
            let searchRange = NSRange(location: baseDirectoryAbsolutePath.count, length: absolutePath.count - baseDirectoryAbsolutePath.count)
            if regularExpression.firstMatch(in: absolutePath, options: [], range: searchRange) != nil {
                filePaths.append(absolutePath)
            }
        }

        return filePaths
    }
}
