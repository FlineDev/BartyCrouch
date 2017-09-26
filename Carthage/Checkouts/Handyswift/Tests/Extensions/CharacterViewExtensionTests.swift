//
//  CharacterViewExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 29.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class CharacterViewExtensionTests: XCTestCase {
    func testSample() {
        XCTAssertNil("".characters.sample)
        XCTAssertNotNil("abc".characters.sample)
        XCTAssertTrue("abc".characters.contains("abc".characters.sample!))
    }

    func testSampleWithSize() {
        XCTAssertNil(([] as [Int]).sample(size: 2))
        XCTAssertEqual([1, 2, 3].sample(size: 2)!.count, 2)
        XCTAssertEqual([1, 2, 3].sample(size: 10)!.count, 10)
    }
}
