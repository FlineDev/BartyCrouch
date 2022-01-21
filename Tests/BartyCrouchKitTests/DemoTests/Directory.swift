import Foundation

final class Directory: Codable {
  struct File: Codable {
    let relativePath: String
    let contents: String

    init(
      baseDirectoryUrl: URL,
      relativePath: String
    ) throws {
      self.relativePath = relativePath
      self.contents = try String(contentsOf: baseDirectoryUrl.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func write(into directory: URL) throws {
      let fileUrl = directory.appendingPathComponent(relativePath)
      let contentsData = contents.data(using: .utf8)!
      try FileManager.default.createFile(
        atPath: fileUrl.path,
        withIntermediateDirectories: true,
        contents: contentsData
      )
    }
  }

  let files: [File]

  init(
    files: [File]
  ) {
    self.files = files
  }

  static func read(fromDirPath directoryPath: String) throws -> Directory {
    let enumerator = FileManager.default.enumerator(atPath: directoryPath)!
    let baseDirectoryUrl = URL(fileURLWithPath: directoryPath, isDirectory: true)
    var files: [File] = []

    while let nextObject = enumerator.nextObject() as? String {
      guard !nextObject.hasSuffix(".xcuserstate") else { continue }
      guard !nextObject.hasSuffix(".DS_Store") else { continue }
      guard enumerator.fileAttributes![FileAttributeKey.type] as! String == FileAttributeType.typeRegular.rawValue
      else { continue }

      let file = try File(baseDirectoryUrl: baseDirectoryUrl, relativePath: nextObject)
      files.append(file)
    }

    return Directory(files: files)
  }
}
