//
//  IntegerTypeExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 29.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class IntegerTypeExtensionTests: XCTestCase {
    func testTimesMethod() {
        var testString = ""

        0.times { testString += "." }
        XCTAssertEqual(testString, "")

        3.times { testString += "." }
        XCTAssertEqual(testString, "...")
    }
}
