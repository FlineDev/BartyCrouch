//@testable import BartyCrouchKit
//import XCTest
//
//// swiftlint:disable force_try
//
//class CommandLineActorTests: XCTestCase {
//    // MARK: - Stored Properties
//    static let stringsFilesDirPath: String = "\(BASE_DIR)/Tests/Resources/StringsFiles"
//
//    let codeFilesDirPath: String = "\(BASE_DIR)/Tests/Resources/CodeFiles/UnsortedKeys"
//    let unsortedKeysStringsFilePath: String = "\(stringsFilesDirPath)/UnsortedKeys/Base.lproj/Localizable.strings"
//    let unsortedKeysDirPath: String = "\(stringsFilesDirPath)/UnsortedKeys"
//
//    // MARK: - Test Callbacks
//    override func setUp() {
//        super.setUp()
//
//        if FileManager.default.fileExists(atPath: unsortedKeysStringsFilePath + ".backup") {
//            try! FileManager.default.removeItem(atPath: unsortedKeysStringsFilePath + ".backup")
//        }
//
//        try! FileManager.default.copyItem(atPath: unsortedKeysStringsFilePath, toPath: unsortedKeysStringsFilePath + ".backup")
//    }
//
//    override func tearDown() {
//        super.tearDown()
//
//        try! FileManager.default.removeItem(atPath: unsortedKeysStringsFilePath)
//        try! FileManager.default.copyItem(atPath: unsortedKeysStringsFilePath + ".backup", toPath: unsortedKeysStringsFilePath)
//        try! FileManager.default.removeItem(atPath: unsortedKeysStringsFilePath + ".backup")
//    }
//
//    // MARK: - Test Methods
//    func testActOnCode() {
//        let args = ["bartycrouch", "code", "-p", codeFilesDirPath, "-l", unsortedKeysDirPath, "-a"]
//
//        CommandLineParser(arguments: args).parse { commonOptions, subCommandOptions in
//            CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)
//
//            guard let updater = StringsFileUpdater(path: self.unsortedKeysStringsFilePath) else {
//                XCTFail("Updater could not be initialized. Is the file missing? Path: \(self.unsortedKeysStringsFilePath)")
//                return
//            }
//
//            let resultingKeys = updater.findTranslations(inString: updater.oldContentString).map { $0.key }
//            let expectedKeys = ["DDD", "ggg", "BBB", "aaa", "FFF", "eee", "ccc"]
//
//            XCTAssertEqual(resultingKeys, expectedKeys)
//        }
//    }
//
//    func testActOnCodeWithSortedOption() {
//        let args = ["bartycrouch", "code", "-p", codeFilesDirPath, "-l", unsortedKeysDirPath, "-a", "-s"]
//
//        CommandLineParser(arguments: args).parse { commonOptions, subCommandOptions in
//            CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)
//
//            guard let updater = StringsFileUpdater(path: self.unsortedKeysStringsFilePath) else {
//                XCTFail("Updater could not be initialized. Is the file missing? Path: \(self.unsortedKeysStringsFilePath)")
//                return
//            }
//
//            let resultingKeys = updater.findTranslations(inString: updater.oldContentString).map { $0.key }
//            let expectedKeys = ["aaa", "BBB", "eee", "FFF", "ggg", "ccc", "DDD"]
//
//            XCTAssertEqual(resultingKeys, expectedKeys)
//        }
//    }
//}
//
//// swiftlint:enable force_try
