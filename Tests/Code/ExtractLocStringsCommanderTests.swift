//
//  ExtractLocStringsCommanderTests.swift
//  BartyCrouch
//
//  Created by Fyodor Volchyok on 12/9/16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class ExtractLocStringsCommanderTests: XCTestCase {
    
    let baseMultipleArgumentTestCodeDirectory = "\(BASE_DIR)/Tests/Assets/Multiple Arguments Code"
    
    override func tearDown() {
        removeLocalizableStringsFilesRecursively(in: URL(fileURLWithPath: baseMultipleArgumentTestCodeDirectory))
    }
    
    func test2Arguments() {
        assert(
            ExtractLocStringsCommander.sharedInstance,
            takesCodeIn: "\(baseMultipleArgumentTestCodeDirectory)/2 Arguments",
            producesResult: [
                "/* test comment */",
                "\"test\" = \"test\";",
                "",
                ""
            ])
    }
    
    func test3ArgumentsValue() {
        assert(
            ExtractLocStringsCommander.sharedInstance,
            takesCodeIn: "\(baseMultipleArgumentTestCodeDirectory)/3 Arguments",
            producesResult: [
                "/* test comment */",
                "\"test\" = \"test value\";",
                "",
                ""
            ])
    }
    
    func test4ArgumentsBundleValue() {
        assert(
            ExtractLocStringsCommander.sharedInstance,
            takesCodeIn: "\(baseMultipleArgumentTestCodeDirectory)/4 Arguments",
            producesResult: [
                "/* test comment */",
                "\"test\" = \"test value\";",
                "",
                ""
            ])
    }

    func assert(_ codeCommander: CodeCommander, takesCodeIn directory: String, producesResult expectedLocalizableStringFileContentLines: [String]) {
        let exportSuccess = codeCommander.export(stringsFilesToPath: directory
            , fromCodeInDirectoryPath: directory)
        XCTAssertTrue(exportSuccess)
        
        do {
            let contentsOfStringsFile = try String(contentsOfFile: directory + "/Localizable.strings")
            let linesInStringsFile = contentsOfStringsFile.components(separatedBy: CharacterSet.newlines)
            XCTAssertEqual(linesInStringsFile, expectedLocalizableStringFileContentLines)
        } catch {
            XCTFail()
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
