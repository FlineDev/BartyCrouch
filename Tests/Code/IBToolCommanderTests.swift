//
//  IBToolCommanderTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 11.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouchFramework

class IBToolCommanderTests: XCTestCase {
    func testiOSExampleStoryboard() {
        let storyboardPath = "\(BASE_DIR)/Tests/Assets/Storyboards/iOS/base.lproj/Example.storyboard"
        let stringsFilePath = storyboardPath + ".strings"

        let exportSuccess = IBToolCommander.shared.export(stringsFileToPath: stringsFilePath, fromIbFileAtPath: storyboardPath)

        XCTAssertTrue(exportSuccess)
    }

    func testOSXExampleStoryboard() {
        let storyboardPath = "\(BASE_DIR)/Tests/Assets/Storyboards/OSX/base.lproj/Example.storyboard"
        let stringsFilePath = storyboardPath + ".strings"

        let exportSuccess = IBToolCommander.shared.export(stringsFileToPath: stringsFilePath, fromIbFileAtPath: storyboardPath)

        XCTAssertTrue(exportSuccess)
    }

    func testtvOSExampleStoryboard() {
        let storyboardPath = "\(BASE_DIR)/Tests/Assets/Storyboards/tvOS/base.lproj/Example.storyboard"
        let stringsFilePath = storyboardPath + ".strings"

        let exportSuccess = IBToolCommander.shared.export(stringsFileToPath: stringsFilePath, fromIbFileAtPath: storyboardPath)

        XCTAssertTrue(exportSuccess)
    }
}
