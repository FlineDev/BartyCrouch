//
//  IBToolCommanderTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 11.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class IBToolCommanderTests: XCTestCase {
    
    func testiOSExampleStoryboard() {
        let stringsFilePath = "\(PROJECT_DIR)/Tests/Assets/Example-iOS.storyboard.strings"
        let storyboardPath = "\(PROJECT_DIR)/Tests/Assets/Example-iOS.storyboard"
        
        let exportSuccess = IBToolCommander.sharedInstance.export(stringsFileToPath: stringsFilePath, fromStoryboardAtPath: storyboardPath)
        
        XCTAssertTrue(exportSuccess)
    }
    
    func testOSXExampleStoryboard() {
        let stringsFilePath = "\(PROJECT_DIR)/Tests/Assets/Example-OSX.storyboard.strings"
        let storyboardPath = "\(PROJECT_DIR)/Tests/Assets/Example-OSX.storyboard"
        
        let exportSuccess = IBToolCommander.sharedInstance.export(stringsFileToPath: stringsFilePath, fromStoryboardAtPath: storyboardPath)
        
        XCTAssertTrue(exportSuccess)
    }
    
    func testtvOSExampleStoryboard() {
        let stringsFilePath = "\(PROJECT_DIR)/Tests/Assets/Example-tvOS.storyboard.strings"
        let storyboardPath = "\(PROJECT_DIR)/Tests/Assets/Example-tvOS.storyboard"
        
        let exportSuccess = IBToolCommander.sharedInstance.export(stringsFileToPath: stringsFilePath, fromStoryboardAtPath: storyboardPath)
        
        XCTAssertTrue(exportSuccess)
    }
    
}
