//// swiftlint:disable file_length
//// swiftlint:disable function_body_length
//// swiftlint:disable type_body_length
//
//@testable import BartyCrouchKit
//import XCTest
//
//class StringsFileUpdaterTests: XCTestCase {
//    // MARK: - Stored Instance Properties
//    static let stringsFilesDirPath: String = "\(BASE_DIR)/Tests/Resources/StringsFiles"
//
//    let oldStringsFilePath: String = "\(stringsFilesDirPath)/OldExample.strings"
//    let longOldStringsFilePath: String = "\(stringsFilesDirPath)/LongOldExample.strings"
//
//    let newStringsFilePath: String = "\(stringsFilesDirPath)/NewExample.strings"
//    let longNewStringsFilePath: String = "\(stringsFilesDirPath)/LongNewExample.strings"
//
//    let testStringsFilePath: String = "\(stringsFilesDirPath)/TestExample.strings"
//
//    let testExamplesRange: ClosedRange<Int> = 0 ... 1
//
//    func testStringsFilePath(_ iteration: Int) -> String {
//        return "\(StringsFileUpdaterTests.stringsFilesDirPath)/TestExample\(iteration).strings"
//    }
//
//    // MARK: - Test Callbacks
//    override func setUp() {
//        super.setUp()
//
//        // ensure temporary files are cleaned up before testing
//        do {
//            try FileManager.default.removeItem(atPath: self.testStringsFilePath)
//        } catch { print("No TestExample.strings to clean up") }
//        do {
//            for index in self.testExamplesRange {
//                try FileManager.default.removeItem(atPath: self.testStringsFilePath(index))
//            }
//        } catch { print("No TestExample{i}.strings to clean up") }
//    }
//
//    override func tearDown() {
//        super.tearDown()
//
//        // cleanup temporary files after testing
//        do {
//            try FileManager.default.removeItem(atPath: self.testStringsFilePath)
//        } catch { print("No TestExample.strings to clean up") }
//        do {
//            for index in self.testExamplesRange {
//                try FileManager.default.removeItem(atPath: self.testStringsFilePath(index))
//            }
//        } catch { print("No TestExample{i}.strings to clean up") }
//    }
//
//    // MARK: - Unit Tests
//    func testFindTranslationsInLines() {
//        let stringsFileUpdater = StringsFileUpdater(path: oldStringsFilePath)!
//
//        let expectedTranslations = [
//            ("35F-cl-mdI.normalTitle", "Example Button 1", " Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; "),
//            ("COa-YO-eGf.normalTitle", "Already Translated", "! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; "),
//            ("cHL-Zc-L39.normalTitle", "Example Button 3", " Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; "),
//            ("test.key", "This is a test key", " Completely custom comment structure in one line "),
//            ("test.key.ignored", "This is a test key to be ignored #bc-ignore!", " Completely custom comment structure in one line to be ignored "),
//            ("test.key.ignoreEmptyStrings", " ", " This key should be ignored when ignoreEmptyKeys is set "),
//            ("abc-12-345.normalTitle", "😀", " Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; "),
//            ("em1-3S-vgp.text", "Refrakční vzdálenost v metrech",
//             " Class = \"UILabel\"; text = \"Refraktionsentfernung in Meter\"; ObjectID = \"em1-3S-vgp\"; ")
//        ]
//
//        let results = stringsFileUpdater.findTranslations(inString: stringsFileUpdater.oldContentString)
//
//        XCTAssertEqual(results.count, expectedTranslations.count)
//
//        var index = 0
//
//        expectedTranslations.forEach { key, value, comment in
//            XCTAssertGreaterThan(results.count, index)
//
//            XCTAssertEqual(results[index].key, key)
//            XCTAssertEqual(results[index].value, value)
//            XCTAssertEqual(results[index].comment, comment)
//
//            index += 1
//        }
//    }
//
//    func testStringFromTranslations() {
//        let translations: [StringsFileUpdater.TranslationEntry] = [
//            ("key1", "value1", "comment1", 1),
//            ("key2", "value2", nil, 2),
//            ("key3", "value3", "comment3", 3)
//        ]
//
//        let expectedString = "\n/*comment1*/\n\"key1\" = \"value1\";\n\n\"key2\" = \"value2\";\n\n/*comment3*/\n\"key3\" = \"value3\";\n"
//
//        let stringsFileUpdater = StringsFileUpdater(path: oldStringsFilePath)!
//        let resultingString = stringsFileUpdater.stringFromTranslations(translations: translations)
//
//        XCTAssertEqual(resultingString, expectedString)
//    }
//
//    func testExampleStringsFileWithEmptyNewValues() {
//        do {
//            try FileManager.default.copyItem(atPath: oldStringsFilePath, toPath: testStringsFilePath)
//            let stringsFileUpdater = StringsFileUpdater(path: testStringsFilePath)!
//
//            let expectedLinesBeforeIncrementalUpdate = [
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
//                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Completely custom comment structure in one line to be ignored */",
//                "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";", "",
//                "/* This key should be ignored when ignoreEmptyKeys is set */",
//                "\"test.key.ignoreEmptyStrings\" = \" \";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; */",
//                "\"abc-12-345.normalTitle\" = \"😀\";", "",
//                "/* Class = \"UILabel\"; text = \"Refraktionsentfernung in Meter\"; ObjectID = \"em1-3S-vgp\"; */",
//                "\"em1-3S-vgp.text\" = \"Refrakční vzdálenost v metrech\";", "", ""
//            ]
//
//            var oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesBeforeIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesBeforeIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//
//            stringsFileUpdater.incrementallyUpdateKeys(
//                withStringsFileAtPath: newStringsFilePath,
//                addNewValuesAsEmpty: true,
//                updateCommentWithBase: false,
//                ignoreEmptyStrings: true
//            )
//
//            let expectedLinesAfterIncrementalUpdate = [
//                "", "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"New Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
//                "\"xyz-12-345.normalTitle\" = \"\";", "",
//                "/* test comment 1", "   test comment 2 */",
//                "\"test.multiline_comment\" = \"\";", "",
//                "/* (test comment with brackets) */",
//                "\"test.brackets_comment\" = \"\";", "",
//                "/* test with % character 1 */", "\"more than 23% or less than 45%\" = \"\";", "",
//                "/* test with % character 2 */", "\"%A%B%C\" = \"\";", "",
//                "/* test with placeholders */", "\"%d%@%.2f\" = \"\";", ""
//            ]
//
//            oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesAfterIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesAfterIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//        } catch {
//            XCTFail((error as NSError).description)
//        }
//    }
//
//    func testExampleStringsFileWithSpecialNewlineSurroundings() {
//        do {
//            try FileManager.default.copyItem(atPath: oldStringsFilePath, toPath: testStringsFilePath)
//            let stringsFileUpdater = StringsFileUpdater(path: testStringsFilePath)!
//
//            let expectedLinesBeforeIncrementalUpdate = [
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
//                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Completely custom comment structure in one line to be ignored */",
//                "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";", "",
//                "/* This key should be ignored when ignoreEmptyKeys is set */",
//                "\"test.key.ignoreEmptyStrings\" = \" \";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; */",
//                "\"abc-12-345.normalTitle\" = \"😀\";", "",
//                "/* Class = \"UILabel\"; text = \"Refraktionsentfernung in Meter\"; ObjectID = \"em1-3S-vgp\"; */",
//                "\"em1-3S-vgp.text\" = \"Refrakční vzdálenost v metrech\";", "", ""
//            ]
//
//            var oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesBeforeIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesBeforeIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//
//            stringsFileUpdater.incrementallyUpdateKeys(
//                withStringsFileAtPath: newStringsFilePath,
//                addNewValuesAsEmpty: true,
//                updateCommentWithBase: false,
//                keepWhitespaceSurroundings: true,
//                ignoreEmptyStrings: true
//            )
//
//            let expectedLinesAfterIncrementalUpdate = [
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"New Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
//                "\"xyz-12-345.normalTitle\" = \"\";", "",
//                "/* test comment 1", "   test comment 2 */",
//                "\"test.multiline_comment\" = \"\";", "",
//                "/* (test comment with brackets) */",
//                "\"test.brackets_comment\" = \"\";", "",
//                "/* test with % character 1 */", "\"more than 23% or less than 45%\" = \"\";", "",
//                "/* test with % character 2 */", "\"%A%B%C\" = \"\";", "",
//                "/* test with placeholders */", "\"%d%@%.2f\" = \"\";", "", ""
//            ]
//
//            oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesAfterIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesAfterIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//        } catch {
//            XCTFail((error as NSError).description)
//        }
//    }
//
//    func testExampleStringsFileWithPrefilledNewValues() {
//        do {
//            try FileManager.default.copyItem(atPath: oldStringsFilePath, toPath: testStringsFilePath)
//            let stringsFileUpdater = StringsFileUpdater(path: testStringsFilePath)!
//
//            let expectedLinesBeforeIncrementalUpdate = [
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"Example Button 3\"; ObjectID = \"cHL-Zc-L39\"; */",
//                "\"cHL-Zc-L39.normalTitle\" = \"Example Button 3\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Completely custom comment structure in one line to be ignored */",
//                "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";", "",
//                "/* This key should be ignored when ignoreEmptyKeys is set */",
//                "\"test.key.ignoreEmptyStrings\" = \" \";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; */",
//                "\"abc-12-345.normalTitle\" = \"😀\";", "",
//                "/* Class = \"UILabel\"; text = \"Refraktionsentfernung in Meter\"; ObjectID = \"em1-3S-vgp\"; */",
//                "\"em1-3S-vgp.text\" = \"Refrakční vzdálenost v metrech\";", "", ""
//            ]
//
//            var oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesBeforeIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesBeforeIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//
//            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: newStringsFilePath, addNewValuesAsEmpty: false, ignoreEmptyStrings: true)
//
//            let expectedLinesAfterIncrementalUpdate = [
//                "", "/* Class = \"UIButton\"; normalTitle = \"New Example Button 1\"; ObjectID = \"35F-cl-mdI\"; */",
//                "\"35F-cl-mdI.normalTitle\" = \"New Example Button 1\";", "",
//                "/*! Class = \"UIButton\"; normalTitle = \"Example Button 2\"; ObjectID = \"COa-YO-eGf\"; */",
//                "\"COa-YO-eGf.normalTitle\" = \"Already Translated\";", "",
//                "/* Completely custom comment structure in one line */",
//                "\"test.key\" = \"This is a test key\";", "",
//                "/* Class = \"UIButton\"; normalTitle = \"New Example Button 4\"; ObjectID = \"xyz-12-345\"; */",
//                "\"xyz-12-345.normalTitle\" = \"New Example Button 4\";", "",
//                "/* test comment 1", "   test comment 2 */",
//                "\"test.multiline_comment\" = \"test.multiline_comment.value\";", "",
//                "/* (test comment with brackets) */",
//                "\"test.brackets_comment\" = \"test.brackets_comment\";", "",
//                "/* test with % character 1 */", "\"more than 23% or less than 45%\" = \"more than 23% or less than 45%\";", "",
//                "/* test with % character 2 */", "\"%A%B%C\" = \"%A%B%C\";", "",
//                "/* test with placeholders */", "\"%d%@%.2f\" = \"%1$d%2$@%3$.2f\";", ""
//            ]
//
//            oldLinesInFile = stringsFileUpdater.oldContentString.components(separatedBy: .newlines)
//
//            XCTAssertEqual(oldLinesInFile.count, expectedLinesAfterIncrementalUpdate.count)
//            for (index, expectedLine) in expectedLinesAfterIncrementalUpdate.enumerated() {
//                XCTAssertEqual(oldLinesInFile[index], expectedLine)
//            }
//        } catch {
//            XCTFail((error as NSError).description)
//        }
//    }
//
//    func testExtractLocale() {
//        let updater = StringsFileUpdater(path: newStringsFilePath)!
//
//        let expectedPairs: [String: StringsFileUpdater.LocaleInfo?] = [
//            "bli/bla/blubb/de.lproj/Main.strings": ("de", nil),
//            "bli/bla/blubb/en-GB.lproj/Main.strings": ("en", "GB"),
//            "bli/bla/blubb/pt-BR.lproj/Main.strings": ("pt", "BR"),
//            "bli/bla/blubb/zh-Hans.lproj/Main.strings": ("zh", "Hans"),
//            "bli/bla/blubb/No-Locale/de-DE/Main.strings": nil
//        ]
//
//        expectedPairs.forEach { path, expectedResult in
//            if expectedResult == nil {
//                XCTAssertNil(updater.extractLocale(fromPath: path))
//            } else {
//                let result = updater.extractLocale(fromPath: path)
//                XCTAssertEqual(result?.language, expectedResult?.language)
//                XCTAssertEqual(result?.region, expectedResult?.region)
//            }
//        }
//    }
//
//    func testTranslateEmptyValues() { // swiftlint:disable:this function_body_length
//        // Note: This test only runs with correct Microsoft Translator API credentials provided
//        let id: String?         = nil       // specify this to run this test
//        let secret: String?     = nil       // specify this to run this test
//
//        if let id = id, let secret = secret {
//            let sourceStringsFilePath = "\(BASE_DIR)/Tests/Resources/StringsFiles/en.lproj/Localizable.strings"
//
//            let expectedTranslatedCarsValues: [String: String] = [
//                "de": "Autos",
//                "ja": "車",
//                "zh-Hans": "汽车"
//            ]
//
//            for locale in ["de", "ja", "zh-Hans"] {
//                let localizableStringsFilePath = "\(BASE_DIR)/Tests/Resources/StringsFiles/\(locale).lproj/Localizable.strings"
//
//                // create temporary file for testing
//                do {
//                    if FileManager.default.fileExists(atPath: localizableStringsFilePath + ".tmp") {
//                        try FileManager.default.removeItem(atPath: localizableStringsFilePath + ".tmp")
//                    }
//
//                    try FileManager.default.copyItem(atPath: localizableStringsFilePath, toPath: localizableStringsFilePath + ".tmp")
//                } catch {
//                    XCTAssertTrue(false)
//                    return
//                }
//
//                let stringsFileUpdater = StringsFileUpdater(path: localizableStringsFilePath + ".tmp")!
//                var translations = stringsFileUpdater.findTranslations(inString: stringsFileUpdater.oldContentString)
//
//                // test before state (update if failing)
//                XCTAssertEqual(translations[0].key, "Test key")
//                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
//                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
//
//                XCTAssertEqual(translations[1].key, "menu.cars")
//                XCTAssertEqual(translations[1].value.utf16.count, 0)
//                XCTAssertEqual(translations[1].value, "")
//                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
//
//                XCTAssertEqual(translations[2].key, "TEST.KEY.UNESCAPED_DOUBLE_QUOTES")
//                XCTAssertEqual(translations[2].value.utf16.count, 0)
//                XCTAssertEqual(translations[2].value, "")
//                XCTAssertEqual(translations[2].comment, nil)
//
//                // run tested method
//                let changedValuesCount = stringsFileUpdater.translateEmptyValues(
//                    usingValuesFromStringsFile: sourceStringsFilePath, clientId: id, clientSecret: secret
//                )
//
//                translations = stringsFileUpdater.findTranslations(inString: stringsFileUpdater.oldContentString)
//
//                XCTAssertEqual(changedValuesCount, 3)
//
//                // test after state (update if failing)
//                XCTAssertEqual(translations.count, 4)
//
//                XCTAssertEqual(translations[0].key, "Test key")
//                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
//                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
//
//                XCTAssertEqual(translations[1].key, "menu.cars")
//                XCTAssertGreaterThan(translations[1].value.utf16.count, 0)
//                XCTAssertEqual(translations[1].value, expectedTranslatedCarsValues[locale])
//                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
//
//                // cleanup temporary file after testing
//                do {
//                    try FileManager.default.removeItem(atPath: localizableStringsFilePath + ".tmp")
//                } catch {
//                    XCTFail("File couldn't be removed at path: \(localizableStringsFilePath).tmp")
//                }
//            }
//
//            let expectedTranslatedBicyclesValues: [String: String] = [
//                "de": "Fahrräder",
//                "ja": "自転車",
//                "zh-Hans": "自行车"
//            ]
//
//            let expectedTranslatedSheSaidStopValues: [String: String] = [
//                "de": "Sie sagte: \\\"Stop!\\\"", // BartyCrouch is expected to escape double quotes
//                "ja": "彼女は言った: '停止'!",
//                "zh-Hans": "她说: '停止' ！"
//            ]
//
//            // test with create keys options
//            for locale in ["de", "ja", "zh-Hans"] {
//                let localizableStringsFilePath = "\(BASE_DIR)/Tests/Resources/StringsFiles/\(locale).lproj/Localizable.strings"
//
//                // create temporary file for testing
//                do {
//                    if FileManager.default.fileExists(atPath: localizableStringsFilePath + ".tmp") {
//                        try FileManager.default.removeItem(atPath: localizableStringsFilePath + ".tmp")
//                    }
//
//                    try FileManager.default.copyItem(atPath: localizableStringsFilePath, toPath: localizableStringsFilePath + ".tmp")
//                } catch {
//                    XCTAssertTrue(false)
//                    return
//                }
//
//                let stringsFileUpdater = StringsFileUpdater(path: localizableStringsFilePath + ".tmp")!
//
//                var translations = stringsFileUpdater.findTranslations(inString: stringsFileUpdater.oldContentString)
//
//                // test before state (update if failing)
//                XCTAssertEqual(translations.count, 3)
//
//                XCTAssertEqual(translations[0].key, "Test key")
//                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
//                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
//
//                XCTAssertEqual(translations[1].key, "menu.cars")
//                XCTAssertEqual(translations[1].value.utf16.count, 0)
//                XCTAssertEqual(translations[1].value, "")
//                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
//
//                // run tested method
//                let changedValuesCount = stringsFileUpdater.translateEmptyValues(
//                    usingValuesFromStringsFile: sourceStringsFilePath, clientId: id, clientSecret: secret
//                )
//
//                translations = stringsFileUpdater.findTranslations(inString: stringsFileUpdater.oldContentString)
//
//                XCTAssertEqual(changedValuesCount, 3)
//
//                // test after state (update if failing)
//                XCTAssertEqual(translations.count, 4)
//
//                XCTAssertEqual(translations[0].key, "Test key")
//                XCTAssertEqual(translations[0].value, "Test value (\(locale))")
//                XCTAssertEqual(translations[0].comment, " A string already localized in all languages. ")
//
//                XCTAssertEqual(translations[1].key, "menu.cars")
//                XCTAssertGreaterThan(translations[1].value.utf16.count, 0)
//                XCTAssertEqual(translations[1].value, expectedTranslatedCarsValues[locale])
//                XCTAssertEqual(translations[1].comment, " A string where value only available in English. ")
//
//                XCTAssertEqual(translations[2].key, "menu.bicycles")
//                XCTAssertGreaterThan(translations[2].value.utf16.count, 0)
//                XCTAssertEqual(translations[2].value, expectedTranslatedBicyclesValues[locale])
//                XCTAssertEqual(translations[2].comment, " A string where key only available in English. ")
//
//                XCTAssertEqual(translations[3].key, "TEST.KEY.UNESCAPED_DOUBLE_QUOTES")
//                XCTAssertGreaterThan(translations[2].value.utf16.count, 0)
//                XCTAssertEqual(translations[3].value, expectedTranslatedSheSaidStopValues[locale])
//                XCTAssertEqual(translations[3].comment, nil)
//
//                // cleanup temporary file after testing
//                do {
//                    try FileManager.default.removeItem(atPath: localizableStringsFilePath + ".tmp")
//                } catch {
//                    XCTFail((error as NSError).description)
//                }
//            }
//        }
//    }
//
//    // MARK: - Performance Tests
//    func testInitPerformance() {
//        measure {
//            100.times {
//                _ = StringsFileUpdater(path: self.longOldStringsFilePath)!
//            }
//        }
//    }
//
//    func testIncrementallyUpdateKeysPerformance() {
//        do {
//            for index in self.testExamplesRange {
//                try FileManager.default.copyItem(atPath: longOldStringsFilePath, toPath: self.testStringsFilePath(index))
//            }
//
//            measure {
//                for index in self.testExamplesRange {
//                    let stringsFileUpdater = StringsFileUpdater(path: self.testStringsFilePath(index))!
//                    stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: self.longNewStringsFilePath, addNewValuesAsEmpty: false)
//                }
//            }
//        } catch {
//            XCTFail((error as NSError).description)
//        }
//    }
//
//    // Note that the method translateEmptyValues is not tested as this would consume unnecessary API requests.
//    // Also it is not the scope of this library to make sure the third party Translation API is fast.
//}
