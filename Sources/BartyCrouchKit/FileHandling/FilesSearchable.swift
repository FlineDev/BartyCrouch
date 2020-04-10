import Foundation

protocol FilesSearchable {
    func findAllFilePaths(inDirectoryPath baseDirectoryPath: String, matching regularExpression: NSRegularExpression, ignoreSuffixes: Set<String>) -> [String]
}

extension FilesSearchable {
    func findAllFilePaths(
        inDirectoryPath baseDirectoryPath: String,
        matching regularExpression: NSRegularExpression,
        ignoreSuffixes: Set<String> = []
    ) -> [String] {
        let baseDirectoryURL = URL(fileURLWithPath: baseDirectoryPath)
        guard let enumerator = FileManager.default.enumerator(at: baseDirectoryURL, includingPropertiesForKeys: nil) else { return [] }

        var filePaths = [String]()
        let dirsToIgnore = Set([".git", "carthage", "pods", "build", ".build", "docs"])
        let baseDirectoryAbsolutePath = baseDirectoryURL.path

        for case let url as URL in enumerator {
            if dirsToIgnore.contains(url.lastPathComponent.lowercased()) {
                enumerator.skipDescendants()
                continue
            }

            let absolutePath = url.path
            let searchRange = NSRange(location: baseDirectoryAbsolutePath.count, length: absolutePath.count - baseDirectoryAbsolutePath.count)
            if regularExpression.firstMatch(in: absolutePath, options: [], range: searchRange) != nil {
                filePaths.append(absolutePath)
            }
        }

        return filePaths.filter { filePath in
            !ignoreSuffixes.contains { filePath.hasSuffix($0) }
        }
    }
}
