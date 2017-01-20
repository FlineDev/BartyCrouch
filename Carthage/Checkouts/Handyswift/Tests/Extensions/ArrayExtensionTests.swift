//
//  ArrayExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

class ArrayExtensionTests: XCTestCase {
    func testSample() {
        XCTAssertNil([].sample())
        XCTAssertNotNil([1, 2, 3].sample())
        XCTAssertTrue([1, 2, 3].contains([1, 2, 3].sample()!))
    }

    func testSampleWithSize() {
        XCTAssertNil(([] as [Int]).sample(size: 2))
        XCTAssertEqual([1, 2, 3].sample(size: 2)!.count, 2)
        XCTAssertEqual([1, 2, 3].sample(size: 10)!.count, 10)
    }

    func testCombinationsWithOther() {
        let numerals = [10, 20, 30]
        let characters = ["A", "B"]

        let combinations = numerals.combinations(with: characters)

        XCTAssertEqual(combinations.count, numerals.count * characters.count)

        // check left side of tuples
        XCTAssertEqual(combinations[0].0, 10)
        XCTAssertEqual(combinations[1].0, 10)

        XCTAssertEqual(combinations[2].0, 20)
        XCTAssertEqual(combinations[3].0, 20)

        XCTAssertEqual(combinations[4].0, 30)
        XCTAssertEqual(combinations[5].0, 30)

        // check right side of tuples
        XCTAssertEqual(combinations[0].1, "A")
        XCTAssertEqual(combinations[1].1, "B")

        XCTAssertEqual(combinations[2].1, "A")
        XCTAssertEqual(combinations[3].1, "B")

        XCTAssertEqual(combinations[4].1, "A")
        XCTAssertEqual(combinations[5].1, "B")
    }
}
