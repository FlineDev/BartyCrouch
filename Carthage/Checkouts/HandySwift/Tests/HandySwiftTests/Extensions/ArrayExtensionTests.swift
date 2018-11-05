//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class ArrayExtensionTests: XCTestCase {
    struct T: Equatable { // swiftlint:disable:this type_name
        let a: Int, b: Int // swiftlint:disable:this identifier_name

        static func == (lhs: T, rhs: T) -> Bool {
            return lhs.a == rhs.a && lhs.b == rhs.b
        }
    }

    let unsortedArray: [T] = [T(a: 0, b: 2), T(a: 1, b: 2), T(a: 2, b: 2), T(a: 3, b: 1), T(a: 4, b: 1), T(a: 5, b: 0)]
    let sortedArray: [T] = [T(a: 5, b: 0), T(a: 3, b: 1), T(a: 4, b: 1), T(a: 0, b: 2), T(a: 1, b: 2), T(a: 2, b: 2)]

    func testSample() {
        XCTAssertNil([].sample)
        XCTAssertNotNil([1, 2, 3].sample)
        XCTAssertTrue([1, 2, 3].contains([1, 2, 3].sample!))
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
        XCTAssertEqual(combinations[0].left, 10)
        XCTAssertEqual(combinations[1].left, 10)

        XCTAssertEqual(combinations[2].left, 20)
        XCTAssertEqual(combinations[3].left, 20)

        XCTAssertEqual(combinations[4].left, 30)
        XCTAssertEqual(combinations[5].left, 30)

        // check right side of tuples
        XCTAssertEqual(combinations[0].right, "A")
        XCTAssertEqual(combinations[1].right, "B")

        XCTAssertEqual(combinations[2].right, "A")
        XCTAssertEqual(combinations[3].right, "B")

        XCTAssertEqual(combinations[4].right, "A")
        XCTAssertEqual(combinations[5].right, "B")
    }

    func testSortByStable() {
        var testArray = [T](unsortedArray)
        testArray.sort(by: { lhs, rhs in lhs.b < rhs.b }, stable: true)
        for index in 0 ..< testArray.count {
            XCTAssertEqual(testArray[index], sortedArray[index])
        }
    }

    func testSortedByStable() {
        let testArray = unsortedArray.sorted(by: { lhs, rhs in lhs.b < rhs.b }, stable: true)
        for index in 0 ..< testArray.count {
            XCTAssertEqual(testArray[index], sortedArray[index])
        }
    }
}
