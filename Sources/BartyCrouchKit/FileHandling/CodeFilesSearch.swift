import Foundation

final class CodeFilesSearch: FilesSearchable {
    private let baseDirectoryPath: String
    private let basePathComponents: [String]

    init(baseDirectoryPath: String) {
        self.baseDirectoryPath = baseDirectoryPath
        self.basePathComponents = URL(fileURLWithPath: baseDirectoryPath).pathComponents
    }

    func shouldSkipFile(at url: URL, subpathsToIgnore: [String]) -> Bool {
        #warning("TODO: write tests to make sure this works even when user provides ignore path 'Hello/World'")
        return Set(url.pathComponents).subtracting(basePathComponents).contains { component in
            subpathsToIgnore.contains(component.lowercased())
        }
    }

    func findCodeFiles(subpathsToIgnore: [String]) -> [String] {
        guard FileManager.default.fileExists(atPath: baseDirectoryPath) else { return [] }
        guard !baseDirectoryPath.hasSuffix(".string") else { return [baseDirectoryPath] }

        let codeFileRegex = try! NSRegularExpression(pattern: "\\.swift\\z", options: .caseInsensitive) // swiftlint:disable:this force_try
        let codeFiles: [String] = findAllFilePaths(
          inDirectoryPath: baseDirectoryPath,
          subpathsToIgnore: subpathsToIgnore,
          matching: codeFileRegex
        )
        return codeFiles
    }
}
