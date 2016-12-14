//
//  Globals.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 07.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// The Main thread level or QOS classes as an enum.
public enum DispatchLevel {
    case main
    case userInteractive
    case userInitiated
    case utility
    case background

    var dispatchQueue: DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main

        case .userInteractive:
            return DispatchQueue.global(qos: .userInteractive)

        case .userInitiated:
            return DispatchQueue.global(qos: .userInitiated)

        case .utility:
            return DispatchQueue.global(qos: .utility)

        case .background:
            return DispatchQueue.global(qos: .background)
        }
    }
}

/// Runs code with delay given in seconds.
///
/// - Parameters:
///   - bySeconds: The delay in seconds.
///   - dispatchLevel: The level that defines the thread type.
///   - closure: The closure to run with delay.
public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}
