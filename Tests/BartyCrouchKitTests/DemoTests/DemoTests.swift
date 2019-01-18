//
//  DemoTests.swift
//  BartyCrouchKitTests
//
//  Created by Cihat Gündüz on 18.01.19.
//

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

        let jsonData = DemoData.untouchedDemoDirectoryJson.data(using: .utf8)!
        let directory = try! JSONDecoder().decode(Directory.self, from: jsonData)
        directory.files.forEach { try! $0.write(into: DemoTests.testDemoDirectoryUrl) }
    }

    override func tearDown() {
        super.tearDown()

        try! FileManager.default.removeContentsOfDirectory(at: DemoTests.testDemoDirectoryUrl)
    }

    func testInit() {
        // TODO: assert no BartyCrouch config file, run init command, check existence of config file
    }
}
