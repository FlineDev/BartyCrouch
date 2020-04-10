//@testable import BartyCrouchKit
//import XCTest
//
//class ExtractLocStringsCommanderTests: XCTestCase {
//    // MARK: - Stored Properties
//    let baseMultipleArgumentFunctionDirectories: [(String?, String)] = [
//        (nil, "\(BASE_DIR)/Tests/Resources/MultipleArgumentsCode"),
//        ("BCLocalizedString", "\(BASE_DIR)/Tests/Resources/MultipleArgumentsCodeCustomFunction")
//    ]
//
//    override func tearDown() {
//        super.tearDown()
//
//        for (_, directory) in baseMultipleArgumentFunctionDirectories {
//            removeLocalizableStringsFilesRecursively(in: URL(fileURLWithPath: directory))
//        }
//    }
//
//    // MARK: - Test Methods
//    func test2Arguments() {
//        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
//            assert(
//                ExtractLocStringsCommander.shared,
//                takesCodeIn: "\(directory)/2Arguments",
//                customFunction: functionName,
//                producesResult: [
//                    "/* test comment */",
//                    "\"test\" = \"test\";",
//                    "",
//                    ""
//                ]
//            )
//        }
//    }
//
//    func test3ArgumentsValue() {
//        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
//            assert(
//                ExtractLocStringsCommander.shared,
//                takesCodeIn: "\(directory)/3Arguments",
//                customFunction: functionName,
//                producesResult: [
//                    "/* test comment */",
//                    "\"test\" = \"test value\";",
//                    "",
//                    ""
//                ]
//            )
//        }
//    }
//
//    func test4ArgumentsBundleValue() {
//        for (functionName, directory) in baseMultipleArgumentFunctionDirectories {
//            assert(
//                ExtractLocStringsCommander.shared,
//                takesCodeIn: "\(directory)/4Arguments",
//                customFunction: functionName,
//                producesResult: [
//                    "/* test comment */",
//                    "\"test\" = \"test value\";",
//                    "",
//                    ""
//                ]
//            )
//        }
//    }
//
//    func assert(
//        _ codeCommander: CodeCommander, takesCodeIn directory: String, customFunction: String?, producesResult expectedLocalizableContentLines: [String]
//    ) {
//        let exportSuccess = codeCommander.export(stringsFilesToPath: directory, fromCodeInDirectoryPath: directory, customFunction: customFunction)
//        XCTAssertTrue(exportSuccess, "Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")
//
//        do {
//            let contentsOfStringsFile = try String(contentsOfFile: directory + "/Localizable.strings")
//            let linesInStringsFile = contentsOfStringsFile.components(separatedBy: CharacterSet.newlines)
//            XCTAssertEqual(
//                linesInStringsFile, expectedLocalizableContentLines, "Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\""
//            )
//        } catch {
//            XCTFail("Failed for \(directory) with function \"\(customFunction ?? "NSLocalizedString")\"")
//        }
//    }
//
//    func removeLocalizableStringsFilesRecursively(in directory: URL) {
//        let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [], options: [], errorHandler: nil)!
//        while case let file as URL = enumerator.nextObject() {
//            if file.pathExtension == "strings" {
//                try? FileManager.default.removeItem(at: file)
//            }
//        }
//    }
//}
