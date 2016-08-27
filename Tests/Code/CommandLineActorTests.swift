//
//  CommandLineActorTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class CommandLineActorTests: XCTestCase {

    // MARK: - Stored Properties

    static let stringsFilesDirPath = "\(BASE_DIR)/Tests/Assets/Strings Files"

    let codeFilesDirPath = "\(BASE_DIR)/Tests/Assets/Code Files/UnsortedKeys"
    let unsortedKeysStringsFilePath = "\(stringsFilesDirPath)/UnsortedKeys/Base.lproj/Localizable.strings"
    let unsortedKeysDirPath = "\(stringsFilesDirPath)/UnsortedKeys"


    // MARK: - Test Callbacks

    override func setUp() {
        if NSFileManager.defaultManager().fileExistsAtPath(unsortedKeysStringsFilePath + ".backup") {
            try! NSFileManager.defaultManager().removeItemAtPath(unsortedKeysStringsFilePath + ".backup")
        }
        try! NSFileManager.defaultManager().copyItemAtPath(unsortedKeysStringsFilePath, toPath: unsortedKeysStringsFilePath + ".backup")
    }

    override func tearDown() {
        try! NSFileManager.defaultManager().removeItemAtPath(unsortedKeysStringsFilePath)
        try! NSFileManager.defaultManager().copyItemAtPath(unsortedKeysStringsFilePath + ".backup", toPath: unsortedKeysStringsFilePath)
        try! NSFileManager.defaultManager().removeItemAtPath(unsortedKeysStringsFilePath + ".backup")
    }


    // MARK: - Test Methods

    func testActOnCode() {

        let args = ["bartycrouch", "code", "-p", codeFilesDirPath, "-l", unsortedKeysDirPath, "-a"]
        CommandLineParser(arguments: args).parse { (commonOptions, subCommandOptions) in
            CommandLineActor().act(commonOptions, subCommandOptions: subCommandOptions)

            guard let updater = StringsFileUpdater(path: self.unsortedKeysStringsFilePath) else {
                XCTFail()
                return
            }

            let resultingKeys = updater.findTranslationsInLines(updater.linesInFile).map { $0.key }
            let expectedKeys = ["DDD", "ggg", "BBB", "aaa", "FFF", "eee", "ccc"]

            XCTAssertEqual(resultingKeys, expectedKeys)
        }

    }
    
    // TODO: tests for actOnInterfaces not yet implemented

    // TODO: tests for actOnTranslate not yet implemented
    
}
