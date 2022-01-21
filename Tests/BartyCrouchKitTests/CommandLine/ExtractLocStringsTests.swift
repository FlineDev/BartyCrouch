//  Created by Christos Koninis on 25/09/2019.

@testable import BartyCrouchKit
import XCTest

// swiftlint:disable force_try

class ExtractLocStringsTests: XCTestCase {
  func testEncodedArgumentPlistFormat() {
    let files = ["file.m", "otherfile.swift", "/path/of/anotherfile.swift"]
    // Disabling whitespace_comment_start due to false positives
    // swiftlint:disable whitespace_comment_start
    let expectedArgumentsPlistString = """
      <?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
      <plist version=\"1.0\"><dict><key>files</key><array><dict><key>path</key><string>file.m</string></dict><dict><key>path</key><string>otherfile.swift\
      </string></dict><dict><key>path</key><string>/path/of/anotherfile.swift</string></dict></array></dict></plist>
      """

    let argumentsPlistData = try! ExtractLocStrings().encodeFilesArguments(files)
    let argumentsPlist = try! argumentsPlistFromData(argumentsPlistData)
    let expectedArgumentsPlist = try! argumentsPlistFromData(expectedArgumentsPlistString.data(using: .utf8)!)

    XCTAssertEqual(argumentsPlist, expectedArgumentsPlist)
  }

  private func argumentsPlistFromData(_ data: Data) throws -> ExtractLocStrings.ArgumentsPlist {
    return try PropertyListDecoder().decode(ExtractLocStrings.ArgumentsPlist.self, from: data)
  }
}
