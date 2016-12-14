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
        XCTAssertNotNil([1,2,3].sample())
        XCTAssertTrue([1,2,3].contains([1,2,3].sample()!))
        
    }
    
    func testSampleWithSize() {
        
        XCTAssertNil(([] as [Int]).sample(size: 2))
        XCTAssertEqual([1,2,3].sample(size: 2)!.count, 2)
        XCTAssertEqual([1,2,3].sample(size: 10)!.count, 10)
        
    }
    
}
