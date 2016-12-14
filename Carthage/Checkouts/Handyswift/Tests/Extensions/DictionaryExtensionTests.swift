//
//  DictionaryExtensionTests.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 16.01.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import XCTest

@testable import HandySwift

class DictionaryExtensionTests: XCTestCase {
        
    func testInitWithSameCountKeysAndValues() {
        
        let keys = Array(0..<100)
        let values = Array(stride(from: 0, to: 10*100, by: 10))
        
        let dict = Dictionary<Int, Int>(keys: keys, values: values)
        XCTAssertNotNil(dict)
        
        if let dict = dict {
            XCTAssertEqual(dict.keys.count, keys.count)
            XCTAssertEqual(dict.values.count, values.count)
            XCTAssertEqual(dict[99]!, values.last!)
            XCTAssertEqual(dict[0]!, values.first!)
        }
        
    }
    
    func testInitWithDifferentCountKeysAndValues() {
        
        let keys = Array(0..<50)
        let values = Array(stride(from: 10, to: 10*100, by: 10))
        
        let dict = Dictionary<Int, Int>(keys: keys, values: values)
        XCTAssertNil(dict)
        
    }
    
    func testMergeOtherDictionary() {
        
        var dict = ["A": "A value", "B": "Old B value", "C": "C value"]
        let otherDict = ["B": "New B value", "D": "D value"]
        
        XCTAssertEqual(dict.count, 3)
        XCTAssertEqual(dict["B"], "Old B value")
        XCTAssertNil(dict["D"])
        
        dict.merge(otherDict)
        
        XCTAssertEqual(dict.count, 4)
        XCTAssertEqual(dict["B"], "New B value")
        XCTAssertEqual(dict["D"], "D value")
        
    }
    
    func testMergedWithOtherDicrionary() {
        
        let immutableDict = ["A": "A value", "B": "Old B value", "C": "C value"]
        let otherDict = ["B": "New B value", "D": "D value"]
        
        let mergedDict = immutableDict.mergedWith(otherDict)
        
        XCTAssertEqual(mergedDict.count, 4)
        XCTAssertEqual(mergedDict["B"], "New B value")
        XCTAssertEqual(mergedDict["D"], "D value")
        
    }
    
}
