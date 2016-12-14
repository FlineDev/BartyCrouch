//
//  StringExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

class StringExtensionTests: XCTestCase {
    
    func testStrip() {
    
        let whitespaceString = " \t BB-8 likes Rey \t "
        XCTAssertEqual(whitespaceString.strip, "BB-8 likes Rey")
        
        let nonWhitespaceString = "Luke Skywalker lives."
        XCTAssertEqual(nonWhitespaceString.strip, nonWhitespaceString)
    
    }
    
    func testIsBlank() {
        
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("  \t  ".isBlank)
        XCTAssertFalse("\n".isBlank)
        XCTAssertFalse("   .    ".isBlank)
        XCTAssertFalse("BB-8".isBlank)
        
    }
    
    func testInitRandomWithLengthAllowedCharactersType() {
        
        10.times {
            
            XCTAssertEqual(String(randomWithLength: 5, allowedCharactersType: .numeric).characters.count, 5)
            XCTAssertFalse(String(randomWithLength: 5, allowedCharactersType: .numeric).characters.contains("a"))
            
            XCTAssertEqual(String(randomWithLength: 8, allowedCharactersType: .alphaNumeric).characters.count, 8)
            XCTAssertFalse(String(randomWithLength: 8, allowedCharactersType: .numeric).characters.contains("."))
            
        }
        
    }
    
}
