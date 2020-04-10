//@testable import BartyCrouchKit
//import XCTest
//
//class FindFilesTests: XCTestCase {
//    class FileFinder: CodeCommander {
//        func export(stringsFilesToPath stringsFilePath: String, fromCodeInDirectoryPath codeDirectoryPath: String, customFunction: String?) -> Bool {
//            return false
//        }
//    }
//
//    func testFindFiles() {
//        let finder = FileFinder()
//
//        let basePath = "\(BASE_DIR)/Tests/Resources/CodeFiles"
//
//        var expectedStringsFilePaths: [String] = [
//            "Subfolder/Subfolder/SwiftExample3.swift",
//            "Subfolder/SwiftExample2.swift",
//            "SwiftExample1.swift",
//            "UnsortedKeys/SwiftExample3.swift"
//        ]
//        expectedStringsFilePaths = expectedStringsFilePaths.map { "\(basePath)/\($0)" }
//
//        let results = finder.findFiles(in: basePath).outputs
//        XCTAssertEqual(results.count, expectedStringsFilePaths.count)
//        XCTAssertEqual(results.sorted(), expectedStringsFilePaths.sorted())
//    }
//}
