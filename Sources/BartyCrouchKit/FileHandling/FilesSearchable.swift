import Foundation

protocol FilesSearchable {
  func findAllFilePaths(
    inDirectoryPath baseDirectoryPath: String,
    subpathsToIgnore: [String],
    matching regularExpression: NSRegularExpression
  ) -> [String]
}

extension FilesSearchable {
  func findAllFilePaths(
    inDirectoryPath baseDirectoryPath: String,
    subpathsToIgnore: [String],
    matching regularExpression: NSRegularExpression
  ) -> [String] {
    let baseDirectoryURL = URL(fileURLWithPath: baseDirectoryPath)
    guard let enumerator = FileManager.default.enumerator(at: baseDirectoryURL, includingPropertiesForKeys: nil) else {
      return []
    }

    var filePaths = [String]()
    let baseDirectoryAbsolutePath = baseDirectoryURL.path
    let codeFilesSearch = CodeFilesSearch(baseDirectoryPath: baseDirectoryAbsolutePath)

    for case let url as URL in enumerator {
      if codeFilesSearch.shouldSkipFile(at: url, subpathsToIgnore: subpathsToIgnore) {
        enumerator.skipDescendants()
        continue
      }

      let absolutePath = url.path
      let searchRange = NSRange(
        location: baseDirectoryAbsolutePath.count,
        length: absolutePath.count - baseDirectoryAbsolutePath.count
      )
      if regularExpression.firstMatch(in: absolutePath, options: [], range: searchRange) != nil {
        filePaths.append(absolutePath)
      }
    }

    return filePaths
  }
}
