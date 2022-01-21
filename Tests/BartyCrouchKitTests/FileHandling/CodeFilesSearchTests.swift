import XCTest
@testable import BartyCrouchKit

final class CodeFilesSearchTests: XCTestCase {
  func testShouldSkipFile() {
    let codeFilesSearch = CodeFilesSearch(baseDirectoryPath: "/")

    let sampleFileUrl = URL(
      fileURLWithPath: "/Users/Me/Developer/Project A/Pods/Lib A/Sources/Supporting Files/InfoPlist.strings"
    )

    XCTAssertTrue(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["pods"]))
    XCTAssertTrue(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["InfoPlist.strings"]))
    XCTAssertTrue(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["pods", "InfoPlist.strings"]))
    XCTAssertTrue(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["Sources/Supporting Files"]))

    XCTAssertFalse(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: []))
    XCTAssertFalse(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["InfoPlist"]))
    XCTAssertFalse(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: [".strings"]))
    XCTAssertFalse(codeFilesSearch.shouldSkipFile(at: sampleFileUrl, subpathsToIgnore: ["Sources/Resources"]))
  }
}
