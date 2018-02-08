//
//  StringsFilesSearchTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 14.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

@testable import BartyCrouchKit
import XCTest

class StringsFilesSearchTests: XCTestCase {
    // MARK: - Test Methods
    func testFindAllIBFiles() {
        let basePath = "\(BASE_DIR)/Tests"

        let expectedIBFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "Base", type: "storyboard") }

        let results = StringsFilesSearch.shared.findAllIBFiles(within: basePath, withLocale: "Base")

        XCTAssertEqual(results.count, expectedIBFilePaths.count)
        XCTAssertEqual(results.sorted(), expectedIBFilePaths.sorted())
    }

	func testFindAllIBFilesInSubFolder() {
		let basePath = "\(BASE_DIR)/Tests/Assets/Storyboards/"

		let expectedIBFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "Base", type: "storyboard") }

		var results = [String]()
		["iOS", "OSX", "tvOS"].forEach { (platform) in
			results += StringsFilesSearch.shared.findAllIBFiles(within: basePath + platform, withLocale: "Base")
		}

		XCTAssertEqual(results.count, expectedIBFilePaths.count)
		XCTAssertEqual(results.sorted(), expectedIBFilePaths.sorted())
	}

    func testFindAllStringsFilesWithLocale() {
        let basePath = "\(BASE_DIR)/Tests"

        let expectedStringsFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "de", type: "strings") }
            + ["\(BASE_DIR)/Tests/Assets/Strings Files/de.lproj/CustomName.strings",
            "\(BASE_DIR)/Tests/Assets/Strings Files/de.lproj/Localizable.strings"]

        let results = StringsFilesSearch.shared.findAllStringsFiles(within: basePath, withLocale: "de")

        XCTAssertEqual(results.count, expectedStringsFilePaths.count)
        XCTAssertEqual(results.sorted(), expectedStringsFilePaths.sorted())
    }

	func testFindAllStringsFilesWithLocaleInSubFolder() {
		let basePath = "\(BASE_DIR)/Tests/Assets/"

		let expectedStringsFilePaths = ["iOS", "OSX", "tvOS"].map { examplePath(platform: $0, locale: "de", type: "strings") }
			+ ["\(BASE_DIR)/Tests/Assets/Strings Files/de.lproj/CustomName.strings",
				"\(BASE_DIR)/Tests/Assets/Strings Files/de.lproj/Localizable.strings"]

		var results = [String]()
		["iOS", "OSX", "tvOS"].forEach { (platform) in
			results += StringsFilesSearch.shared.findAllStringsFiles(within: basePath + "Storyboards/" + platform, withLocale: "de")
		}
		results += StringsFilesSearch.shared.findAllStringsFiles(within: basePath + "Strings Files", withLocale: "de")

		XCTAssertEqual(results.count, expectedStringsFilePaths.count)
		XCTAssertEqual(results.sorted(), expectedStringsFilePaths.sorted())
	}

    func testiOSFindAllLocalesForStringsFile() {
        let baseStoryboardPath = examplePath(platform: "iOS", locale: "base", type: "storyboard")
        let expectedStringsPaths = ["de", "en", "ja", "zh-Hans"].map { examplePath(platform: "iOS", locale: $0, type: "strings") }

        let results = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: baseStoryboardPath)

        XCTAssertEqual(results.count, expectedStringsPaths.count)
        XCTAssertEqual(results.sorted(), expectedStringsPaths.sorted())
    }

    func testFindAllStringsFiles() {
        let basePath = "\(BASE_DIR)/Tests"

        let expectedStringsFilePaths = (
            ["de", "en", "ja", "zh-Hans"].map { stringsFilePath(name: "Localizable", locale: $0) }
            + ["de", "en", "ja", "zh-Hans"].map { stringsFilePath(name: "CustomName", locale: $0) }
            + ["Localizable", "CustomName"].map { stringsFilePath(name: $0, locale: "Base", subpath: "Multiple Tables") }
            + [stringsFilePath(name: "Localizable", locale: "Base", subpath: "UnsortedKeys")]
        ).sorted()

        let notExpectedStringsFilePath = (
            ["en"].map { stringsFilePath(name: "InfoPlist", locale: $0) }
        ).sorted()

        let results = StringsFilesSearch.shared.findAllStringsFiles(within: basePath).sorted()

        XCTAssertEqual(results.count, expectedStringsFilePaths.count)
        XCTAssertEqual(results, expectedStringsFilePaths)

        for anUnexpectedStringsFilePath in notExpectedStringsFilePath {
            XCTAssertFalse(results.contains(anUnexpectedStringsFilePath))
        }
    }

    // MARK: - Helpers
    func examplePath(platform: String, locale: String, type: String) -> String {
        return "\(BASE_DIR)/Tests/Assets/Storyboards/\(platform)/\(locale).lproj/Example.\(type)"
    }

    func stringsFilePath(name: String, locale: String, subpath: String = "") -> String {
        let path = !subpath.isEmpty && subpath.last != "/" ? "\(subpath)/" : subpath
        return "\(BASE_DIR)/Tests/Assets/Strings Files/\(path)\(locale).lproj/\(name).strings"
    }
}
