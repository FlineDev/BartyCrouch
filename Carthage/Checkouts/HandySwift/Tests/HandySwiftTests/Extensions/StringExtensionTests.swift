//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class StringExtensionTests: XCTestCase {
    func testStrip() {
        let whitespaceString = " \n\t BB-8 likes Rey \t\n "
        XCTAssertEqual(whitespaceString.stripped(), "BB-8 likes Rey")

        let nonWhitespaceString = "Luke Skywalker lives."
        XCTAssertEqual(nonWhitespaceString.stripped(), nonWhitespaceString)
    }

    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("  \t  ".isBlank)
        XCTAssertTrue("\n".isBlank)
        XCTAssertFalse("   .    ".isBlank)
        XCTAssertFalse("BB-8".isBlank)
    }

    func testInitRandomWithLengthAllowedCharactersType() {
        10.times {
            XCTAssertEqual(String(randomWithLength: 5, allowedCharactersType: .numeric).count, 5)
            XCTAssertFalse(String(randomWithLength: 5, allowedCharactersType: .numeric).contains("a"))

            XCTAssertEqual(String(randomWithLength: 8, allowedCharactersType: .alphaNumeric).count, 8)
            XCTAssertFalse(String(randomWithLength: 8, allowedCharactersType: .numeric).contains("."))
        }
    }

    func testSample() {
        XCTAssertNil("".sample)
        XCTAssertNotNil("abc".sample)
        XCTAssertTrue("abc".contains("abc".sample!))
    }

    func testSampleWithSize() {
        XCTAssertNil(([] as [Int]).sample(size: 2))
        XCTAssertEqual([1, 2, 3].sample(size: 2)!.count, 2)
        XCTAssertEqual([1, 2, 3].sample(size: 10)!.count, 10)
    }
}
