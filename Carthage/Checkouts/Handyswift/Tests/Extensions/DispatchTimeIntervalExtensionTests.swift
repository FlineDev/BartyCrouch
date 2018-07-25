//
//  Created by Cihat Gündüz on 13.02.17.
//  Copyright © 2017 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class DispatchTimeIntervalTests: XCTestCase {
    func testTimeInterval() {
        let dispatchTimeInterval = DispatchTimeInterval.milliseconds(500)
        let timeInterval = dispatchTimeInterval.timeInterval

        XCTAssertEqual(timeInterval, 0.5, accuracy: 0.001)
    }
}
