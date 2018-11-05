//
//  Created by Cihat Gündüz on 18.02.17.
//  Copyright © 2017 Flinesoft. All rights reserved.
//

@testable import HandySwift
import XCTest

class TimeIntervalExtensionTests: XCTestCase {
    func testUnitInitialization() {
        XCTAssertEqual(Timespan.days(0.5), 12 * 60 * 60, accuracy: 0.001)
        XCTAssertEqual(Timespan.hours(0.5), 30 * 60, accuracy: 0.001)
        XCTAssertEqual(Timespan.minutes(0.5), 30, accuracy: 0.001)
        XCTAssertEqual(Timespan.seconds(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(Timespan.milliseconds(0.5), 0.5 / 1_000, accuracy: 0.001)
        XCTAssertEqual(Timespan.microseconds(0.5), 0.5 / 1_000_000, accuracy: 0.001)
        XCTAssertEqual(Timespan.nanoseconds(0.5), 0.5 / 1_000_000_000, accuracy: 0.001)
    }

    func testUnitConversion() {
        let timespan = Timespan.hours(4)
        let multipledTimespan = timespan * 3

        XCTAssertEqual(multipledTimespan.days, 0.5, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.hours, 12, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.minutes, 12 * 60, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.seconds, 12 * 60 * 60, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.milliseconds, 12 * 60 * 60 * 1_000, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.microseconds, 12 * 60 * 60 * 1_000_000, accuracy: 0.001)
        XCTAssertEqual(multipledTimespan.nanoseconds, 12 * 60 * 60 * 1_000_000_000, accuracy: 0.001)
    }
}
