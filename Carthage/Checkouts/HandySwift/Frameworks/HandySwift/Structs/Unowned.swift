//
//  Unowned.swift
//  HandySwift
//
//  Created by Murat Yilmaz on 19.05.18.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

import Foundation

/// A wrapper for storing unowned references to a `Wrapped` instance.
public struct Unowned<Wrapped> where Wrapped: AnyObject {
    /// The value of `Wrapped` stored as unowned reference
    public unowned var value: Wrapped

    /// Creates an instance that stores the given value.
    public init(_ value: Wrapped) {
        self.value = value
    }
}

extension Unowned: CustomDebugStringConvertible where Wrapped: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return value.debugDescription
    }
}

extension Unowned: Decodable where Wrapped: Decodable {
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        self.value = try Wrapped(from: decoder)
    }
}

extension Unowned: Equatable where Wrapped: Equatable {
    /// Returns a Boolean value indicating whether two instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: An optional value to compare.
    ///   - rhs: Another optional value to compare.
    public static func == (lhs: Unowned<Wrapped>, rhs: Unowned<Wrapped>) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Unowned: Encodable where Wrapped: Encodable {
    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
