// Created by Cihat Gündüz on 18.01.19.

@testable import BartyCrouchKit
import XCTest

@available(OSX 10.12, *)
class DemoTests: XCTestCase {
    static let testDemoDirectoryUrl: URL = FileManager.default.temporaryDirectory.appendingPathComponent("Demo")

    // NOTE: Uncomment and run to update demo directory data – also comment out setUp() and tearDown() to prevent issues
//    func testSnapshotDemoData() {
//        DemoData.record(directoryPath: "/absolute/path/to/BartyCrouch/Demo/Untouched")
//    }

    override func setUp() {
        super.setUp()

        TestHelper.shared.isStartedByUnitTests = true
        try! FileManager.default.removeContentsOfDirectory(at: DemoTests.testDemoDirectoryUrl)

        let jsonData = DemoData.untouchedDemoDirectoryJson.data(using: .utf8)!
        let directory = try! JSONDecoder().decode(Directory.self, from: jsonData)
        directory.files.forEach { try! $0.write(into: DemoTests.testDemoDirectoryUrl) }

        FileManager.default.changeCurrentDirectoryPath(DemoTests.testDemoDirectoryUrl.path)
    }

    override func tearDown() {
        super.tearDown()

        try! FileManager.default.removeContentsOfDirectory(at: DemoTests.testDemoDirectoryUrl)
    }

    func testInit() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: Configuration.fileName))

        try! InitCommand().execute()

        XCTAssertTrue(FileManager.default.fileExists(atPath: Configuration.fileName))
        XCTAssertEqual(TestHelper.shared.printOutputs.count, 1)
        XCTAssertEqual(TestHelper.shared.printOutputs[0].level, .success)
        XCTAssertEqual(TestHelper.shared.printOutputs[0].message, "Successfully created file \(Configuration.fileName)")
    }

    func testLint() {
        try! InitCommand().execute()
        XCTAssertTrue(FileManager.default.fileExists(atPath: Configuration.fileName))

        TestHelper.shared.reset()
        try! LintCommand().execute()

        XCTAssertEqual(TestHelper.shared.printOutputs.count, 10)

        for printOutput in TestHelper.shared.printOutputs.dropLast() {
            XCTAssertEqual(printOutput.level, .warning)
        }

        for (indices, langCode) in [([0, 1, 2], "de"), ([3, 4, 5], "en"), ([6, 7, 8], "tr")] {
            XCTAssertEqual(TestHelper.shared.printOutputs[indices[0]].message, "Found 2 translations for key 'Existing Duplicate Key'. Other entries at: [13]")
            XCTAssertEqual(TestHelper.shared.printOutputs[indices[0]].line, 11)

            XCTAssertEqual(TestHelper.shared.printOutputs[indices[1]].message, "Found 2 translations for key 'Existing Duplicate Key'. Other entries at: [11]")
            XCTAssertEqual(TestHelper.shared.printOutputs[indices[1]].line, 13)

            XCTAssertEqual(TestHelper.shared.printOutputs[indices[2]].message, "Found empty value for key 'Existing Empty Value Key'.")
            XCTAssertEqual(TestHelper.shared.printOutputs[indices[2]].line, 15)

            indices.forEach { index in
                XCTAssertEqual(
                    String(TestHelper.shared.printOutputs[index].file!.suffix(from: "/private".endIndex)),
                    DemoTests.testDemoDirectoryUrl.appendingPathComponent("Demo/\(langCode).lproj/Localizable.strings").path
                )
            }
        }

        XCTAssertEqual(TestHelper.shared.printOutputs.last!.level, .warning)
        XCTAssertEqual(TestHelper.shared.printOutputs.last!.message, "6 issue(s) found in 3 file(s). Executed 2 checks in 8 Strings file(s) in total.")
    }
}
