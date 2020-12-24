import Foundation

final class CodeFilesSearch: FilesSearchable {
    private let baseDirectoryPath: String

    init(baseDirectoryPath: String) {
        self.baseDirectoryPath = baseDirectoryPath
    }

    static func shouldSkipFile(at url: URL) -> Bool {
        let dirsToIgnore = Set([".git", "carthage", "pods", "build", ".build", "docs"])
        return url.pathComponents.contains { component in
            dirsToIgnore.contains(component.lowercased())
        }
    }

    func findCodeFiles() -> [String] {
        guard FileManager.default.fileExists(atPath: baseDirectoryPath) else { return [] }
        guard !baseDirectoryPath.hasSuffix(".string") else { return [baseDirectoryPath] }

        let codeFileRegex = try! NSRegularExpression(pattern: "\\.swift\\z", options: .caseInsensitive) // swiftlint:disable:this force_try
        let codeFiles: [String] = findAllFilePaths(inDirectoryPath: baseDirectoryPath, matching: codeFileRegex)
        return codeFiles
    }
}
