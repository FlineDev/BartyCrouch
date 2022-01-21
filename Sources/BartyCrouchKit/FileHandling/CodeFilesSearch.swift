import Foundation

final class CodeFilesSearch: FilesSearchable {
  private let baseDirectoryPath: String
  private let basePathComponents: [String]

  init(
    baseDirectoryPath: String
  ) {
    self.baseDirectoryPath = baseDirectoryPath
    self.basePathComponents = URL(fileURLWithPath: baseDirectoryPath).pathComponents
  }

  func shouldSkipFile(at url: URL, subpathsToIgnore: [String]) -> Bool {
    var subpath = url.path

    if let potentialBaseDirSubstringRange = subpath.range(of: baseDirectoryPath) {
      if potentialBaseDirSubstringRange.lowerBound == subpath.startIndex {
        subpath.removeSubrange(potentialBaseDirSubstringRange)
      }
    }

    let subpathComponents = subpath.components(separatedBy: "/").filter { !$0.isBlank }
    for subpathToIgnore in subpathsToIgnore {
      let subpathToIgnoreComponents = subpathToIgnore.components(separatedBy: "/")
      if subpathComponents.containsCaseInsensitive(subarray: subpathToIgnoreComponents) {
        return true
      }
    }

    return false
  }

  func findCodeFiles(subpathsToIgnore: [String]) -> [String] {
    guard FileManager.default.fileExists(atPath: baseDirectoryPath) else { return [] }
    guard !baseDirectoryPath.hasSuffix(".string") else { return [baseDirectoryPath] }

    let codeFileRegex = try! NSRegularExpression(pattern: "\\.swift\\z", options: .caseInsensitive)  // swiftlint:disable:this force_try
    let codeFiles: [String] = findAllFilePaths(
      inDirectoryPath: baseDirectoryPath,
      subpathsToIgnore: subpathsToIgnore,
      matching: codeFileRegex
    )
    return codeFiles
  }
}

extension Array where Element == String {
  func containsCaseInsensitive(subarray: [Element]) -> Bool {
    guard let firstSubArrayElement = subarray.first else { return false }

    for (index, element) in enumerated() {
      // sample: this = [a, b, c], subarray = [b, c], firstIndex = 1, subRange = 1 ..< 3
      if element.lowercased() == firstSubArrayElement.lowercased() {
        let subRange = index..<index + subarray.count
        let subRangeElements = self[subRange]
        return subRangeElements.map { $0.lowercased() } == subarray.map { $0.lowercased() }
      }
    }

    return false
  }
}
