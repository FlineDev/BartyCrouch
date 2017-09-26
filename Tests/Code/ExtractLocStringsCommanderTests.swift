//
//  ExtractLocStringsCommanderTests.swift
//  BartyCrouch
//
//  Created by Fyodor Volchyok on 12/9/16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

@testable import BartyCrouchKit
import XCTest

class ExtractLocStringsCommanderTests: XCTestCase {
    // MARK: - Stored Properties
    let baseMultipleArgumentFunctionDirectories: [(String?, String)] = [
        (nil, "\(BASE_DIR)/Tests/Assets/Multiple Arguments Code"),
        ("BCLocalizedString", "\(BASE_DIR)/Tests/Assets/Multiple Arguments Code Custom Function")
    ]

    let baseMultipleTablesFunctionDirectoryData: [(String?, String)] = [
        (nil, "\(BASE_DIR)/Tests/Assets/Multiple Tables Code"),
        ("BCLocalizedString", "\(BASE_DIR)/Tests/Assets/Multiple Tables Code Custom Function")
    ]

    override func tearDown() {
        super.tearDown()

        for (_, directory) in baseMultipleArgumentFunctionDirectories + baseMultipleTablesFunctionDirectoryData {
            removeLocalizableStringsFilesRecursively(in: URL(fileURLWithPath: directory))
        }
    }

    // MARK: - Test Methods
    func test2Arguments() {
        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
            assert(
                ExtractLocStringsCommander.shared,
                takesCodeIn: "\(directory)/2 Arguments",
                customFunction: functionName,
                producesResult: [
                    "/* test comment */",
                    "\"test\" = \"test\";",
                    "",
                    ""
                ]
            )
        }
    }

    func test3ArgumentsValue() {
        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
            assert(
                ExtractLocStringsCommander.shared,
                takesCodeIn: "\(directory)/3 Arguments",
                customFunction: functionName,
                producesResult: [
                    "/* test comment */",
                    "\"test\" = \"test value\";",
                    "",
                    ""
                ]
            )
        }
    }

    func test4ArgumentsBundleValue() {
        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
            assert(
                ExtractLocStringsCommander.shared,
                takesCodeIn: "\(directory)/4 Arguments",
                customFunction: functionName,
                producesResult: [
                    "/* test comment */",
                    "\"test\" = \"test value\";",
                    "",
                    ""
                ]
            )
        }
    }

    func testMultipleTables() {
        for (functionName, directory) in baseMultipleTablesFunctionDirectoryData {
            assert(
                ExtractLocStringsCommander.shared,
                takesCodeIn: directory,
                customFunction: functionName,
                producesResult: [
                    "/* test comment in default table name */",
                    "\"test.defaultTableName\" = \"test.defaultTableName\";",
                    "",
                    ""
                ]
            )

            assert(
                ExtractLocStringsCommander.shared,
                takesCodeIn: directory,
                customFunction: functionName,
                tableName: "CustomName",
                producesResult: [
                    "/* test comment in custom table name */",
                    "\"test.customTableName\" = \"test.customTableName\";",
                    "",
                    ""
                ]
            )
        }
    }

    func assert(
        _ codeCommander: CodeCommander, takesCodeIn directory: String, customFunction: String?, tableName: String = "Localizable",
        producesResult expectedLocalizableContentLines: [String]
    ) {
        let exportSuccess = codeCommander.export(stringsFilesToPath: directory, fromCodeInDirectoryPath: directory, customFunction: customFunction)
        XCTAssertTrue(exportSuccess, "Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")

        do {
            let contentsOfStringsFile = try String(contentsOfFile: directory + "/\(tableName).strings")
            let linesInStringsFile = contentsOfStringsFile.components(separatedBy: CharacterSet.newlines)
            XCTAssertEqual(
                linesInStringsFile, expectedLocalizableContentLines,
                "Failed for \(tableName).strings in \(directory) with function \"\(customFunction ?? "NSLocalizedString")\""
            )
        } catch {
            XCTFail("Failed for \(tableName).strings in \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")
        }
    }

    func removeLocalizableStringsFilesRecursively(in directory: URL) {
        let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [], options: [], errorHandler: nil)!
        while case let file as URL = enumerator.nextObject() {
            if file.pathExtension == "strings" {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
