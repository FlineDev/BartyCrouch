//
//  IntegerTypeExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 18.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

class IntExtensionTests: XCTestCase {
        
    func testInitRandomBelow() {
        
        10.times {
            XCTAssertTrue(Int(randomBelow: 15) < 15)
            XCTAssertTrue(Int(randomBelow: 15) >= 0)
            XCTAssertTrue(Int(randomBelow: 0) == 0)
            XCTAssertTrue(Int(randomBelow: -1) == 0)
        }
        
    }
    
}
