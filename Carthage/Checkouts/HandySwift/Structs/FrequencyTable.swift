//
//  Created by Cihat Gündüz on 03.01.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Data structure to retrieve random values with their frequency taken into account.
public struct FrequencyTable<T> {
    // MARK: - Sub Types
    typealias Entry = (value: T, frequency: Int)

    // MARK: - Stored Instance Properties
    private let valuesWithFrequencies: [Entry]

    /// Contains all values the amount of time of their frequencies.
    private let frequentValues: [T]

    // MARK: - Initializers
    /// Creates a new FrequencyTable instance with values and their frequencies provided.
    ///
    /// - Parameters:
    ///   - values: An array full of values to be saved into the frequency table.
    ///   - frequencyClosure: The closure to specify the frequency for a specific value.
    public init(values: [T], frequencyClosure: (T) -> Int) {
        valuesWithFrequencies = values.map { ($0, frequencyClosure($0)) }
        frequentValues = valuesWithFrequencies.reduce([]) { memo, entry in
            return memo + Array(repeating: entry.value, count: entry.frequency)
        }
    }

    // MARK: - Computed Instance Properties
    /// - Returns: A random value taking frequencies into account or nil if values empty.
    public var sample: T? { return frequentValues.sample }

    // MARK: - Instance Methods
    /// Returns an array of random values taking frequencies into account or nil if values empty.
    ///
    /// - Parameters:
    ///     - size: The size of the resulting array of random values.
    ///
    /// - Returns: An array of random values or nil if values empty.
    public func sample(size: Int) -> [T]? {
        guard size > 0 && !frequentValues.isEmpty else { return nil }
        return Array(0..<size).map { _ in sample! }
    }
}
