//
//  SortedArrayTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

class SortedArrayTests: XCTestCase {
    
    func testInitialization() {
        
        let intArray: [Int] = [9, 1, 3, 2, 5, 4, 6, 0, 8, 7]
        let sortedIntArray = SortedArray(array: intArray)
        
        XCTAssertEqual(sortedIntArray.array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
    }
    
    func testFirstMatchingIndex() {
        
        let emptyArray: [Int] = []
        let sortedEmptyArray = SortedArray(array: emptyArray)
        
        XCTAssertNil(sortedEmptyArray.firstMatchingIndex{ _ in true })

        let intArray: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sortedIntArray = SortedArray(array: intArray)
        
        let expectedIndex = 3
        let resultingIndex = sortedIntArray.firstMatchingIndex{ $0 >= 3 }
        
        XCTAssertEqual(resultingIndex, expectedIndex)
        
    }
    
    func testSubArrayToIndex() {
        
        let intArray: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sortedIntArray = SortedArray(array: intArray)
        
        let index = sortedIntArray.firstMatchingIndex{ $0 > 5 }!
        let sortedSubArray = sortedIntArray.subArray(toIndex: index)
        
        XCTAssertEqual(sortedSubArray.array, [0, 1, 2, 3, 4, 5])
        
    }
    
    func testSubArrayFromIndex() {
        
        let intArray: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sortedIntArray = SortedArray(array: intArray)
        
        let index = sortedIntArray.firstMatchingIndex{ $0 > 5 }!
        let sortedSubArray = sortedIntArray.subArray(fromIndex: index)
        
        XCTAssertEqual(sortedSubArray.array, [6, 7, 8, 9])
        
    }
    
}
