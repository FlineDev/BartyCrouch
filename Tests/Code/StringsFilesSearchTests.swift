//
//  StringsFilesSearchTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 14.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class StringsFilesSearchTests: XCTestCase {
    // MARK: - Test Methods

    func testFindAllIBFiles() {
        let basePath = "\(BASE_DIR)/Tests"

        let expectedIBFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "Base", type: "storyboard") }

        let results = StringsFilesSearch.shared.findAllIBFiles(within: basePath, withLocale: "Base")

        XCTAssertEqual(results.count, expectedIBFilePaths.count)
        XCTAssertEqual(results, expectedIBFilePaths)
    }

    func testFindAllStringsFiles() {
        let basePath = "\(BASE_DIR)/Tests"

        let expectedStringsFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "de", type: "strings") }
            + ["\(BASE_DIR)/Tests/Assets/Strings Files/de.lproj/Localizable.strings"]

        let results = StringsFilesSearch.shared.findAllStringsFiles(within: basePath, withLocale: "de")

        XCTAssertEqual(results.count, expectedStringsFilePaths.count)
        XCTAssertEqual(results, expectedStringsFilePaths)
    }

    func testiOSFindAllLocalesForStringsFile() {
        let baseStoryboardPath = examplePath(platform: "iOS", locale: "base", type: "storyboard")
        let expectedStringsPaths = ["de", "en", "ja", "zh-Hans"].map { examplePath(platform: "iOS", locale: $0, type: "strings") }

        let results = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: baseStoryboardPath)

        XCTAssertEqual(results.count, expectedStringsPaths.count)
        XCTAssertEqual(results, expectedStringsPaths)
    }


    // MARK: - Helpers

    func examplePath(platform: String, locale: String, type: String) -> String {
        return "\(BASE_DIR)/Tests/Assets/Storyboards/\(platform)/\(locale).lproj/Example.\(type)"
    }
}
