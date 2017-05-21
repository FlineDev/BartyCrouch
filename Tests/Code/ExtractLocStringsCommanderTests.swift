//
//  ExtractLocStringsCommanderTests.swift
//  BartyCrouch
//
//  Created by Fyodor Volchyok on 12/9/16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouchKit

class ExtractLocStringsCommanderTests: XCTestCase {
    // MARK: - Stored Properties

    let baseMultipleArgumentFunctionDirectories: [(String?, String)] = [
     (nil, "\(BASE_DIR)/Tests/Assets/Multiple Arguments Code"),
     ("BCLocalizedString", "\(BASE_DIR)/Tests/Assets/Multiple Arguments Code Custom Function")
    ]

    override func tearDown() {
        for (_, directory) in baseMultipleArgumentFunctionDirectories {
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

    func assert(_ codeCommander: CodeCommander, takesCodeIn directory: String, customFunction: String?, producesResult expectedLocalizableContentLines: [String]) {
        let exportSuccess = codeCommander.export(stringsFilesToPath: directory, fromCodeInDirectoryPath: directory, customFunction: customFunction)
        XCTAssertTrue(exportSuccess, "Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")

        do {
            let contentsOfStringsFile = try String(contentsOfFile: directory + "/Localizable.strings")
            let linesInStringsFile = contentsOfStringsFile.components(separatedBy: CharacterSet.newlines)
            XCTAssertEqual(linesInStringsFile, expectedLocalizableContentLines, "Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")
        } catch {
            XCTFail("Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")

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
