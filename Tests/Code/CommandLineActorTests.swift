//
//  CommandLineActorTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

@testable import BartyCrouchKit
import XCTest

// swiftlint:disable force_try

class CommandLineActorTests: XCTestCase {
    // MARK: - Stored Properties
    static let stringsFilesDirPath = "\(BASE_DIR)/Tests/Assets/Strings Files"

    static let unsortedKeysCodeFilesDirPath = "\(BASE_DIR)/Tests/Assets/Code Files/UnsortedKeys"
    static let unsortedKeysStringsFilePath = "\(stringsFilesDirPath)/UnsortedKeys/Base.lproj/Localizable.strings"
    static let unsortedKeysDirPath = "\(stringsFilesDirPath)/UnsortedKeys"

    static let multipleTablesCodeFilesDirPath = "\(BASE_DIR)/Tests/Assets/Multiple Tables Code/"
    static let multipleTablesDirPath = "\(stringsFilesDirPath)/Multiple Tables"

    static let filePathsToBackup = [
        unsortedKeysStringsFilePath,
        multipleTablesStringsFilePath(forTableName: "Localizable"),
        multipleTablesStringsFilePath(forTableName: "CustomName")
    ]

    // MARK: - Test Callbacks
    override func setUp() {
        super.setUp()

        for filePath in CommandLineActorTests.filePathsToBackup {
            if FileManager.default.fileExists(atPath: filePath + ".backup") {
                try! FileManager.default.removeItem(atPath: filePath + ".backup")
            }

            try! FileManager.default.copyItem(atPath: filePath, toPath: filePath + ".backup")
        }
    }

    override func tearDown() {
        super.tearDown()

        for filePath in CommandLineActorTests.filePathsToBackup {
            try! FileManager.default.removeItem(atPath: filePath)
            try! FileManager.default.copyItem(atPath: filePath + ".backup", toPath: filePath)
            try! FileManager.default.removeItem(atPath: filePath + ".backup")
        }
    }

    // MARK: - Test Methods
    func testActOnCode() {
        let args = [
            "bartycrouch", "code",
            "-p", CommandLineActorTests.unsortedKeysCodeFilesDirPath,
            "-l", CommandLineActorTests.unsortedKeysDirPath,
            "-a"
        ]
        CommandLineParser(arguments: args).parse { commonOptions, subCommandOptions in
            CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)

            guard let updater = StringsFileUpdater(path: CommandLineActorTests.unsortedKeysStringsFilePath) else {
                XCTFail()
                return
            }

            let resultingKeys = updater.findTranslations(inString: updater.oldContentString).map { $0.key }
            let expectedKeys = ["DDD", "ggg", "BBB", "aaa", "FFF", "eee", "ccc"]

            XCTAssertEqual(resultingKeys, expectedKeys)
        }
    }

    func testActOnCodeWithSortedOption() {
        let args = [
            "bartycrouch", "code",
            "-p", CommandLineActorTests.unsortedKeysCodeFilesDirPath,
            "-l", CommandLineActorTests.unsortedKeysDirPath,
            "-a", "-s"
        ]
        CommandLineParser(arguments: args).parse { commonOptions, subCommandOptions in
            CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)

            guard let updater = StringsFileUpdater(path: CommandLineActorTests.unsortedKeysStringsFilePath) else {
                XCTFail()
                return
            }

            let resultingKeys = updater.findTranslations(inString: updater.oldContentString).map { $0.key }
            let expectedKeys = ["aaa", "BBB", "eee", "FFF", "ggg", "ccc", "DDD"]

            XCTAssertEqual(resultingKeys, expectedKeys)
        }
    }

    func testActOnCodeMultipleTables() {
        let args = [
            "bartycrouch", "code",
            "-p", CommandLineActorTests.multipleTablesCodeFilesDirPath,
            "-l", CommandLineActorTests.multipleTablesDirPath,
            "-e"
        ]
        CommandLineParser(arguments: args).parse { commonOptions, subCommandOptions in
            CommandLineActor().act(commonOptions: commonOptions, subCommandOptions: subCommandOptions)

            let expectedKeysPerTable = [
                "Localizable": ["test.defaultTableName"],
                "CustomName": ["test.customTableName"]
            ]

            for (tableName, expectedKeys) in expectedKeysPerTable {
                let filePath = CommandLineActorTests.multipleTablesStringsFilePath(forTableName: tableName)
                guard let updater = StringsFileUpdater(path: filePath) else {
                    XCTFail()
                    return
                }

                let resultingKeys = updater.findTranslations(inString: updater.oldContentString).map { $0.key }

                XCTAssertEqual(resultingKeys, expectedKeys)
            }
        }
    }

    static func multipleTablesStringsFilePath(forTableName tableName: String) -> String {
        return "\(multipleTablesDirPath)/Base.lproj/\(tableName).strings"
    }
}

// swiftlint:enable force_try
