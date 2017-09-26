//
//  GenStringsCommanderTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

@testable import BartyCrouchKit
import XCTest

class GenStringsCommanderTests: XCTestCase {
    // MARK: - Stored Properties
    let exampleCodeFunctionDirectoryData: [(String?, String)] = [
        (nil, "\(BASE_DIR)/Tests/Assets/Code Files"),
        ("BCLocalizedString", "\(BASE_DIR)/Tests/Assets/Code Files Custom Function")
    ]

    // MARK: - Test Configuration Methods
    override func tearDown() {
        super.tearDown()

        do {
            for (_, path) in exampleCodeFunctionDirectoryData {
                try FileManager.default.removeItem(atPath: path + "/Localizable.strings")
            }
        } catch {
            // do nothing
        }
    }

    // MARK: - Test Methods
    func testCodeExamples() {
        for (customFunction, path) in exampleCodeFunctionDirectoryData {
            let exportSuccess = GenStringsCommander.shared.export(stringsFilesToPath: path, fromCodeInDirectoryPath: path, customFunction: customFunction)

            do {
                let contentsOfStringsFile = try String(contentsOfFile: path + "/Localizable.strings")

                let linesInStringsFile = contentsOfStringsFile.components(separatedBy: .newlines)
                XCTAssertEqual(linesInStringsFile, [
                    "/* No comment provided by engineer. */",
                    "\"%010d and %03.f\" = \"%1$d and %2$.f\";",
                    "",
                    "/* No comment provided by engineer. */",
                    "\"%@ and %.2f\" = \"%1$@ and %2$.2f\";",
                    "",
                    "/* Ignoring stringsdict key #bc-ignore! */",
                    "\"%d ignore(s)\" = \"%d ignore(s)\";",
                    "",
                    "/* No comment provided by engineer. */",
                    "\"ccc\" = \"ccc\";",
                    "",
                    "/* (test comment with brackets) */",
                    "\"test.brackets_comment\" = \"test.brackets_comment\";",
                    "",
                    "/* test comment 1",
                    "   test comment 2 */",
                    "\"test.multiline_comment\" = \"test.multiline_comment\";",
                    "",
                    "/* Comment for TestKey1 */",
                    "\"TestKey1\" = \"TestKey1\";",
                    "",
                    "/* Comment for TestKey1 */",
                    "\"TestKey2\" = \"TestKey2\";",
                    "",
                    ""
                ], "Failed for \(path) with function \"\(customFunction ?? "NSLocalizedString")\"")
            } catch {
                XCTFail("Failed for \(path) with function \"\(customFunction ?? "NSLocalizedString")\"")
            }

            XCTAssertTrue(exportSuccess, "Failed for \(path) with function \"\(customFunction ?? "NSLocalizedString")\"")
        }
    }
}
