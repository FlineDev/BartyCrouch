// Created by Cihat Gündüz on 23.01.19.

import Foundation

final class CodeFilesSearch: FilesSearchable {
    private let baseDirectoryPath: String

    init(baseDirectoryPath: String) {
        self.baseDirectoryPath = baseDirectoryPath
    }

    func findCodeFiles() -> [String] {
        guard FileManager.default.fileExists(atPath: baseDirectoryPath) else { return [] }
        guard !baseDirectoryPath.hasSuffix(".string") else { return [baseDirectoryPath] }

        let codeFileRegex = try! NSRegularExpression(pattern: "\\.swift\\z", options: .caseInsensitive)
        let codeFiles: [String] = findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: codeFileRegex)
        return codeFiles
    }
}
