//
//  StringsFileUpdaterTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 11.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class StringsFileUpdaterTests: XCTestCase {
    
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
            ("COa-YO-eGf.normalTitle", "Already Translated", "! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; "),
            ("cHL-Zc-L39.normalTitle", "Example Button 3", " Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; "),
            ("test.key", "This is a test key", " Completely custom comment structure in one line "),
            ("test.key.ignored", "This is a test key to be ignored #bc-ignore!", " Completely custom comment structure in one line to be ignored "),
            ("abc-12-345.normalTitle", "😀", " Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; ")
        ]
        
        let results = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
        
        var index = 0
        
        expectedTranslations.forEach { (key, value, comment) in
            XCTAssertGreaterThan(results.count, index)
            
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
                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";",
                "",
                "/* Completely custom comment structure in one line */",
                "\"test.key\" = \"This is a test key\";",
                "",
                "/* Completely custom comment structure in one line to be ignored */",
                "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";",
                ""
            ]
            
            for (index, expectedLine) in expectedLinesBeforeIncrementalUpdate.enumerate() {
                XCTAssertEqual(stringsFileUpdater.linesInFile[index], expectedLine)
            }
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath, addNewValuesAsEmpty: true, updateCommentWithBase: false)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"New Example Button 1\";",
                "",
                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"\";",
                "",
                "/* Completely custom comment structure in one line */",
                "\"test.key\" = \"This is a test key\";",
                ""
            ]
            
            for (index, expectedLine) in expectedLinesAfterIncrementalUpdate.enumerate() {
                XCTAssertEqual(stringsFileUpdater.linesInFile[index], expectedLine)
            }
            
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
                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";",
                "",
                "/* Completely custom comment structure in one line */",
                "\"test.key\" = \"This is a test key\";",
                "",
                "/* Completely custom comment structure in one line to be ignored */",
                "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";",
                ""
            ]
            
            for (index, expectedLine) in expectedLinesBeforeIncrementalUpdate.enumerate() {
                XCTAssertEqual(stringsFileUpdater.linesInFile[index], expectedLine)
            }
            
            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath, addNewValuesAsEmpty: false)
            
            let expectedLinesAfterIncrementalUpdate = [
                "",
                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
                "\"35F-cl-mdI.normalTitle\" = \"New Example Button 1\";",
                "",
                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";",
                "",
                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
                "\"xyz-12-345.normalTitle\" = \"New Example Button 4\";",
                "",
                "/* Completely custom comment structure in one line */",
                "\"test.key\" = \"This is a test key\";",
                ""
            ]
            
            for (index, expectedLine) in expectedLinesAfterIncrementalUpdate.enumerate() {
                XCTAssertEqual(stringsFileUpdater.linesInFile[index], expectedLine)
            }
            
        } catch {
            XCTAssertTrue(false, (error as NSError).description)
        }
        
    }
    
    func testExtractLocale() {

        let updater = StringsFileUpdater(path: newStringsFilePath)!
        
        let expectedPairs: [String: (String, String?)?] = [
            "bli/bla/blubb/de.lproj/Main.strings":              ("de", nil),
            "bli/bla/blubb/en-GB.lproj/Main.strings":           ("en", "GB"),
            "bli/bla/blubb/pt-BR.lproj/Main.strings":           ("pt", "BR"),
            "bli/bla/blubb/zh-Hans.lproj/Main.strings":         ("zh", "Hans"),
            "bli/bla/blubb/No-Locale/de-DE/Main.strings":       nil
        ]
        
        expectedPairs.forEach { path, expectedResult in
            
            if expectedResult == nil {
                
                XCTAssertNil(updater.extractLocale(fromPath: path))
                
            } else {
                
                let result = updater.extractLocale(fromPath: path)
                XCTAssertEqual(result?.0, expectedResult?.0)
                XCTAssertEqual(result?.1, expectedResult?.1)
                
            }
            
        }
        
    }
    
    func testTranslateEmptyValues() {
        
        // Note: This test only runs with correct Microsoft Translator API credentials provided
        let id: String?         = nil       // specify this to run this test
        let secret: String?     = nil       // specify this to run this test
        
        if let id = id, secret = secret {
            
            let sourceStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/en.lproj/Localizable.strings"
            
            let expectedTranslatedValues: [String: String] = [
                "de":       "Autos",
                "ja":       "車",
                "zh-Hans":  "汽车"
            ]
            
            for locale in ["de", "ja", "zh-Hans"] {
                
                let localizableStringsFilePath = "\(PROJECT_DIR)/Tests/Assets/StringsFiles/\(locale).lproj/Localizable.strings"
                
                // create temporary file for testing
                do {
                    if NSFileManager.defaultManager().fileExistsAtPath(localizableStringsFilePath + ".tmp") {
                        try NSFileManager.defaultManager().removeItemAtPath(localizableStringsFilePath + ".tmp")
                    }
                    try NSFileManager.defaultManager().copyItemAtPath(localizableStringsFilePath, toPath: localizableStringsFilePath + ".tmp")
                } catch {
                    XCTAssertTrue(false)
                    return
                }
                
                let stringsFileUpdater = StringsFileUpdater(path: localizableStringsFilePath + ".tmp")!
                
                var translations = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
                
                
                // test before state (update if failing)
                
                XCTAssertEqual(translations.first!.key, "Test key")
                XCTAssertEqual(translations.first!.value, "Test value (\(locale))")
                XCTAssertEqual(translations.first!.comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations.last!.key, "menu.cars")
                XCTAssertEqual(translations.last!.value.utf16.count, 0)
                XCTAssertEqual(translations.last!.value, "")
                XCTAssertEqual(translations.last!.comment, " A string only available in English. ")
                
                
                // run tested method
                
                let changedValuesCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: sourceStringsFilePath, clientId: id, clientSecret: secret)
                
                translations = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
                
                XCTAssertEqual(changedValuesCount, 1)
                
                
                // test after state (update if failing)
                
                XCTAssertEqual(translations.first!.key, "Test key")
                XCTAssertEqual(translations.first!.value, "Test value (\(locale))")
                XCTAssertEqual(translations.first!.comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations.last!.key, "menu.cars")
                XCTAssertGreaterThan(translations.last!.value.utf16.count, 0)
                XCTAssertEqual(translations.last!.value, expectedTranslatedValues[locale])
                XCTAssertEqual(translations.last!.comment, " A string only available in English. ")
                
                
                // cleanup temporary file after testing
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(localizableStringsFilePath + ".tmp")
                } catch {
                    XCTAssertTrue(false)
                }
            }
            
        }
    }
    
}
