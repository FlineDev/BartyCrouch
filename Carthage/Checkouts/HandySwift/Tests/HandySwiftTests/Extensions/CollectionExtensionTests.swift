//
//  Created by Stepanov Pavel on 08/07/2018.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class CollectionExtensionTests: XCTestCase {
    func testTrySubscript() {
        let testArray = [0, 1, 2, 3, 20]

        XCTAssertNil(testArray[try: 8])
        XCTAssert(testArray[try: -1] == nil)
        XCTAssert(testArray[try: 0] != nil)
        XCTAssert(testArray[try: 4] == testArray[4])

        let secondTestArray = [Int]()
        XCTAssertNil(secondTestArray[try: 0])
    }
}
