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
    
    override func setUp() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath("\(PROJECT_DIR)/Tests/Assets/StringsFiles/TestExample.strings")
        } catch {
            print("Could not cleanup TestExample.strings")
        }
    }
    
    func testExampleStringsFileWithEmptyNewValues() {
        let oldStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/OldExample.strings"
        let newStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/NewExample.strings"
        let testStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/TestExample.strings"
        
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
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesAfterIncrementalUpdate)
            
        } catch {
            XCTAssertTrue(false, (error as NSError).description)
        }
        
    }
    
    func testExampleStringsFileWithPrefilledNewValues() {
        let oldStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/OldExample.strings"
        let newStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/NewExample.strings"
        let testStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/TestExample.strings"
        
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
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Example Button 2\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"Example Button 4\";",
                ""
            ]
            
            XCTAssertEqual(stringsFileUpdater.linesInFile, expectedLinesAfterIncrementalUpdate)
            
        } catch {
            XCTAssertTrue(false, (error as NSError).description)
        }
        
    }
    
}
