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
    
    // MARK: - Stored Instance Properties
    
    let oldStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/OldExample.strings"
    let longOldStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/LongOldExample.strings"
    
    let newStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/NewExample.strings"
    let longNewStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/LongNewExample.strings"
    
    let testStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/TestExample.strings"
    func testStringsFilePath(iteration: Int) -> String {
        return "\(BASE_DIR)/Tests/Assets/StringsFiles/TestExample\(iteration).strings"
    }
    
    let testExamplesRange = 0...1
    
    
    // MARK: - Test Callbacks
    
    override func setUp() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.testStringsFilePath)
            // cleanup temporary file after testing
            for i in self.testExamplesRange {
                try NSFileManager.defaultManager().removeItemAtPath(self.testStringsFilePath(i))
            }
        } catch {
            print("No TestExample.strings to clean up")
        }
    }
    
    
    // MARK: - Unit Tests
    
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
        
        let translations: [StringsFileUpdater.TranslationEntry] = [
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
            XCTFail((error as NSError).description)
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
            XCTFail((error as NSError).description)
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
        let id: String?         = "Cruciverber"       // specify this to run this test
        let secret: String?     = "RFykBwu#6=Tja0hzlQ1gA3zhNFl#lB2Z"       // specify this to run this test
        
        if let id = id, secret = secret {
            
            let sourceStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/en.lproj/Localizable.strings"
            
            let expectedTranslatedCarsValues: [String: String] = [
                "de":       "Autos",
                "ja":       "車",
                "zh-Hans":  "汽车"
            ]
            
            for locale in ["de", "ja", "zh-Hans"] {
                
                let localizableStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/\(locale).lproj/Localizable.strings"
                
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
                XCTAssertEqual(translations[0].key, "Test key")
                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations[1].key, "menu.cars")
                XCTAssertEqual(translations[1].value.utf16.count, 0)
                XCTAssertEqual(translations[1].value, "")
                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")

                XCTAssertEqual(translations[2].key, "TEST.KEY.UNESCAPED_DOUBLE_QUOTES")
                XCTAssertEqual(translations[2].value.utf16.count, 0)
                XCTAssertEqual(translations[2].value, "")
                XCTAssertEqual(translations[2].comment, nil)
                
                
                // run tested method
                let changedValuesCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: sourceStringsFilePath, clientId: id, clientSecret: secret)
                
                translations = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
                
                XCTAssertEqual(changedValuesCount, 3)
                
                
                // test after state (update if failing)
                XCTAssertEqual(translations.count, 4)
                
                XCTAssertEqual(translations[0].key, "Test key")
                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations[1].key, "menu.cars")
                XCTAssertGreaterThan(translations[1].value.utf16.count, 0)
                XCTAssertEqual(translations[1].value, expectedTranslatedCarsValues[locale])
                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
                
                
                // cleanup temporary file after testing
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(localizableStringsFilePath + ".tmp")
                } catch {
                    XCTFail()
                }
            }
            
            let expectedTranslatedBicyclesValues: [String: String] = [
                "de":       "Fahrräder",
                "ja":       "自転車",
                "zh-Hans":  "自行车"
            ]

            let expectedTranslatedSheSaidStopValues: [String: String] = [
                "de":       "Sie sagte: \\\"Stop!\\\"", // BartyCrouch is expected to escape double quotes
                "ja":       "彼女は言った: '停止'!",
                "zh-Hans":  "她说: '停止' ！"
            ]
            
            // test with create keys options
            for locale in ["de", "ja", "zh-Hans"] {
                
                let localizableStringsFilePath = "\(BASE_DIR)/Tests/Assets/StringsFiles/\(locale).lproj/Localizable.strings"
                
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
                XCTAssertEqual(translations.count, 3)
                
                XCTAssertEqual(translations[0].key, "Test key")
                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations[1].key, "menu.cars")
                XCTAssertEqual(translations[1].value.utf16.count, 0)
                XCTAssertEqual(translations[1].value, "")
                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
                
                
                // run tested method
                let changedValuesCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: sourceStringsFilePath, clientId: id, clientSecret: secret)
                
                translations = stringsFileUpdater.findTranslationsInLines(stringsFileUpdater.linesInFile)
                
                XCTAssertEqual(changedValuesCount, 3)
                
                
                // test after state (update if failing)
                XCTAssertEqual(translations.count, 4)
                
                XCTAssertEqual(translations[0].key, "Test key")
                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
                
                XCTAssertEqual(translations[1].key, "menu.cars")
                XCTAssertGreaterThan(translations[1].value.utf16.count, 0)
                XCTAssertEqual(translations[1].value, expectedTranslatedCarsValues[locale])
                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
                
                XCTAssertEqual(translations[2].key, "menu.bicycles")
                XCTAssertGreaterThan(translations[2].value.utf16.count, 0)
                XCTAssertEqual(translations[2].value, expectedTranslatedBicyclesValues[locale])
                XCTAssertEqual(translations[2].comment, " A string where key only available in English. ")

                XCTAssertEqual(translations[3].key, "TEST.KEY.UNESCAPED_DOUBLE_QUOTES")
                XCTAssertGreaterThan(translations[2].value.utf16.count, 0)
                XCTAssertEqual(translations[3].value, expectedTranslatedSheSaidStopValues[locale])
                XCTAssertEqual(translations[3].comment, nil)

                
                // cleanup temporary file after testing
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(localizableStringsFilePath + ".tmp")
                } catch {
                    XCTFail((error as NSError).description)
                }
            }
            
        }
    }
    
    
    // MARK: - Performance Tests
    
    func testInitPerformance() {
        
        measureBlock {
            for _ in self.testExamplesRange {
                StringsFileUpdater(path: self.longOldStringsFilePath)!
            }
        }
        
    }
    
    func testIncrementallyUpdateKeysPerformance() {
        
        do {
            
            for i in self.testExamplesRange {
                try NSFileManager.defaultManager().copyItemAtPath(longOldStringsFilePath, toPath: self.testStringsFilePath(i))
            }
            
            measureBlock {
                for i in self.testExamplesRange {
                    let stringsFileUpdater = StringsFileUpdater(path: self.testStringsFilePath(i))!
                    stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: self.longNewStringsFilePath, addNewValuesAsEmpty: false)
                }
            }
            
        } catch {
            XCTFail((error as NSError).description)
        }

    }
    
    // Note that the method translateEmptyValues is not tested as this would consume unnecessary API requests.
    // Also it is not the scope of this library to make sure the third party Translation API is fast.
    
}
