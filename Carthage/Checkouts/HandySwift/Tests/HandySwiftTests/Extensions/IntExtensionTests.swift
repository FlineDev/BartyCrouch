//
//  Created by Cihat Gündüz on 18.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class IntExtensionTests: XCTestCase {
    func testInitRandomBelow() {
        10.times {
            XCTAssertTrue(Int(randomBelow: 15)! < 15)
            XCTAssertTrue(Int(randomBelow: 15)! >= 0)
            XCTAssertNil(Int(randomBelow: 0))
            XCTAssertNil(Int(randomBelow: -1))
        }
    }

    func testTimesMethod() {
        var testString = ""

        0.times { testString += "." }
        XCTAssertEqual(testString, "")

        3.times { testString += "." }
        XCTAssertEqual(testString, "...")
    }

    func testTimesMakeMethod() {
        var testArray = 0.timesMake { 1 }
        XCTAssertEqual(testArray, [])

        testArray = 3.timesMake { 1 }
        XCTAssertEqual(testArray, [1, 1, 1])

        var index = 0
        testArray = 3.timesMake { index += 1; return index }
        XCTAssertEqual(testArray, [1, 2, 3])
    }
}
