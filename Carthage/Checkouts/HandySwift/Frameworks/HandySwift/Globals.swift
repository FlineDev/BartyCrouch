//
//  Created by Cihat Gündüz on 07.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Runs code with delay given in seconds. Uses the main thread if not otherwise specified.
///
/// - Parameters:
///   - delayTime: The duration of the delay. E.g. `.seconds(1)` or `.milliseconds(200)`.
///   - qosClass: The global QOS class to be used or `nil` to use the main thread. Defaults to `nil`.
///   - closure: The code to run with a delay.
public func delay(by delayTime: Timespan, qosClass: DispatchQoS.QoSClass? = nil, _ closure: @escaping () -> Void) {
    let dispatchQueue = qosClass != nil ? DispatchQueue.global(qos: qosClass!) : DispatchQueue.main
    dispatchQueue.asyncAfter(deadline: DispatchTime.now() + delayTime, execute: closure)
}
