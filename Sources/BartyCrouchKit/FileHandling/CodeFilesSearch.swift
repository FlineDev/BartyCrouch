import Foundation

final class CodeFilesSearch: FilesSearchable {

    static let dirsToIgnore = Set([".git", "carthage", "pods", "build", ".build", "docs"])

    private let baseDirectoryPath: String
    private let basePathComponents: [String]

    init(baseDirectoryPath: String) {
        self.baseDirectoryPath = baseDirectoryPath

        basePathComponents = URL(fileURLWithPath: baseDirectoryPath).pathComponents
    }

    func shouldSkipFile(at url: URL) -> Bool {
        return Set(url.pathComponents).subtracting(basePathComponents).contains { component in
            Self.dirsToIgnore.contains(component.lowercased())
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
