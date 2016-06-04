//
//  GenStringsCommanderTests.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import BartyCrouch

class GenStringsCommanderTests: XCTestCase {
    
    let exampleCodeFilesDirectoryPath = "\(BASE_DIR)/Tests/Assets/CodeFiles"
    
    override func tearDown() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(exampleCodeFilesDirectoryPath + "/Localizable.strings")
        } catch {
            // do nothing
        }
    }
    
    func testiOSExampleStoryboard() {
        
        let exportSuccess = GenStringsCommander.sharedInstance.export(stringsFilesToPath: exampleCodeFilesDirectoryPath
            , fromCodeInDirectoryPath: exampleCodeFilesDirectoryPath)
        
        do {
            let contentsOfStringsFile = try String(contentsOfFile: exampleCodeFilesDirectoryPath + "/Localizable.strings")
            XCTAssertNotNil(contentsOfStringsFile)
            
            let linesInStringsFile = contentsOfStringsFile.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            XCTAssertEqual(linesInStringsFile, [
                "/* No comment provided by engineer. */",
                "\"%010d and %03.f\" = \"%1$d and %2$.f\";",
                "",
                "/* No comment provided by engineer. */",
                "\"%@ and %.2f\" = \"%1$@ and %2$.2f\";",
                "",
                "/* #bc-ignore! Ignoring stringsdict key */",
                "\"%d ignores(s)\" = \"%d ignores(s)\";",
                "",
                "/* Comment for TestKey1 */",
                "\"TestKey1\" = \"TestKey1\";",
                "",
                "/* Comment for TestKey1 */",
                "\"TestKey2\" = \"TestKey2\";",
                "",
                ""
            ])
            
        } catch {
            XCTFail()
        }
        
        
        XCTAssertTrue(exportSuccess)
    }
    
}
