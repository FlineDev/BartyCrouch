//
//  Created by Cihat Gündüz on 28.01.17.
//  Copyright © 2017 Flinesoft. All rights reserved.
//

import Foundation

extension DispatchTimeInterval {
    /// - Returns: The time in seconds using the`TimeInterval` type.
    public var timeInterval: TimeInterval {
        switch self {
        case .seconds(let seconds):
            return Double(seconds)

        case .milliseconds(let milliseconds):
            return Double(milliseconds) / Timespan.millisecondsPerSecond

        case .microseconds(let microseconds):
            return Double(microseconds) / Timespan.microsecondsPerSecond

        case .nanoseconds(let nanoseconds):
            return Double(nanoseconds) / Timespan.nanosecondsPerSecond

        case .never:
            return TimeInterval.infinity
        }
    }
}
