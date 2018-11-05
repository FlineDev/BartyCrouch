//
//  Created by Murat Yilmaz on 19.05.18.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

import Foundation

/// A wrapper for storing weak references to a `Wrapped` instance.
public struct Weak<Wrapped>: ExpressibleByNilLiteral where Wrapped: AnyObject {
    /// The value of `Wrapped` stored as weak reference
    public weak var value: Wrapped?

    /// Creates an instance that stores the given value.
    public init(_ value: Wrapped) {
        self.value = value
    }

    /// Evaluates the given closure when this `Weak` instance is not `nil`,
    /// passing the value as a parameter.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `nil`,
    ///   returns `nil`.
    public func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U? {
        guard let value = value else { return nil }

        return try transform(value)
    }

    /// Evaluates the given closure when this `Weak` instance is not `nil`,
    /// passing the value as a parameter.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `nil`,
    ///   returns `nil`.
    public func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U? {
        guard let value = value else { return nil }

        return try transform(value)
    }

    /// Creates an instance initialized with `nil`.
    public init(nilLiteral: ()) {
        self.value = nil
    }
}

extension Weak: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return value.debugDescription
    }
}

extension Weak: Decodable where Wrapped: Decodable {
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        self.value = try? Wrapped(from: decoder)
    }
}

extension Weak: Equatable where Wrapped: Equatable {
    /// Returns a Boolean value indicating whether two instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: An optional value to compare.
    ///   - rhs: Another optional value to compare.
    public static func == (lhs: Weak<Wrapped>, rhs: Weak<Wrapped>) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Weak: Encodable where Wrapped: Encodable {
    /// Encodes this optional value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
