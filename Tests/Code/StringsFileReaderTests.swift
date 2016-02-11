//
//  StringsFileReaderTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 11.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class StringsFileReaderTests: XCTestCase {
    
    let oldStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/OldExample.strings"
    let newStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/NewExample.strings"
    let testStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/TestExample.strings"
    
    override func setUp() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath("\(PROJECT_DIR)/Tests/Assets/StringsFiles/TestExample.strings")
        } catch {
            print("Could not cleanup TestExample.strings")
        }
    }
    
    func testFindTranslationsInLines() {
        
        let stringsFileUpdater = StringsFileUpdater(path: oldStringsFilePath)!
        
        let expectedTranslations = [
            ("35F-cl-mdI.normalTitle", "Example Button 1", " Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; "),
            ("COa-YO-eGf.normalTitle", "Example Button 2", " Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; "),
            ("cHL-Zc-L39.normalTitle", "Example Button 3", " Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; ")
        ]
        
        let results = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
        
        var index = 0
        
        expectedTranslations.forEach { (key, value, comment) in
            XCTAssertEqual(results[index].0, key)
            XCTAssertEqual(results[index].1, value)
            XCTAssertEqual(results[index].2, comment)
            
            index += 1
        }
        
    }
    
    func testStringFromTranslations() {
        
        let translations: [(key: String, value: String, comment: String?)] = [
            ("key1", "value1", "comment1"),
            ("key2", "value2", nil),
            ("key3", "value3", "comment3")
        ]
        
        let expectedString = "\n/*comment1*/\n\"key1\" = \"value1\";\n\n\"key2\" = \"value2\";\n\n/*comment3*/\n\"key3\" = \"value3\";\n"
        
        let stringsFileUpdater = StringsFileUpdater(path: oldStringsFilePath)!
        let resultingString = stringsFileUpdater.stringFromTranslations(translations)
        
        XCTAssertEqual(resultingString, expectedString)
        
    }
    
    func testExampleStringsFileWithEmptyNewValues() {
        
        do {
            try NSFileManager.defaultManager().copyItemAtPath(oldStringsFilePath, toPath: testStringsFilePath)
            let stringsFileUpdater = StringsFileUpdater(path: testStringsFilePath)!
            
            let expectedLinesBeforeIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesBeforeIncrementalUpdate)
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath, addNewValuesAsEmpty: true)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesAfterIncrementalUpdate)
            
        } catch {
            XCTAssertTrue(false, (error as NSError).description)
        }
        
    }
    
    func testExampleStringsFileWithPrefilledNewValues() {
        
        do {
            try NSFileManager.defaultManager().copyItemAtPath(oldStringsFilePath, toPath: testStringsFilePath)
            let stringsFileUpdater = StringsFileUpdater(path: testStringsFilePath)!
            
            let expectedLinesBeforeIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesBeforeIncrementalUpdate)
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath, addNewValuesAsEmpty: false)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"New Example Button 4\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesAfterIncrementalUpdate)
            
        } catch {
            XCTAssertTrue(false, (error as NSError).description)
        }
        
    }
    
}
