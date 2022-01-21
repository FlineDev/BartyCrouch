@testable import BartyCrouchKit
import XCTest

class CodeFileHandlerTests: XCTestCase {
  static let testDemoDirectoryUrl: URL = FileManager.default.temporaryDirectory.appendingPathComponent("Demo")

  override func setUp() {
    super.setUp()

    TestHelper.shared.reset()
    TestHelper.shared.isStartedByUnitTests = true
    try! FileManager.default.removeContentsOfDirectory(at: DemoTests.testDemoDirectoryUrl)

    let jsonData = DemoData.untouchedDemoDirectoryJson.data(using: .utf8)!
    let directory = try! JSONDecoder().decode(Directory.self, from: jsonData)
    directory.files.forEach { try! $0.write(into: CodeFileHandlerTests.testDemoDirectoryUrl) }

    FileManager.default.changeCurrentDirectoryPath(CodeFileHandlerTests.testDemoDirectoryUrl.path)
  }

  override func tearDown() {
    super.tearDown()

    try! FileManager.default.removeContentsOfDirectory(at: CodeFileHandlerTests.testDemoDirectoryUrl)
  }

  func testFindCaseToLangCodeMappins() {
    let supportingLanguagesCodeFilePath: String = CodeFileHandlerTests.testDemoDirectoryUrl
      .appendingPathComponent("Demo/BartyCrouch.swift").path
    let caseToLangMappings: [String: String]? = CodeFileHandler(path: supportingLanguagesCodeFilePath)
      .findCaseToLangCodeMappings(typeName: "BartyCrouch")

    XCTAssertNotNil(caseToLangMappings)
    XCTAssertEqual(caseToLangMappings?["german"], "de")
    XCTAssertEqual(caseToLangMappings?["japanese"], "ja")
    XCTAssertEqual(caseToLangMappings?["chineseTraditional"], "zh-Hant")
  }
}
