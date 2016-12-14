//
//  FrequencyTable.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 03.01.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

/// Data structure to retrieve random values with their frequency taken into account.
public struct FrequencyTable<T> {

    // MARK: - Stored Instance Properties

    fileprivate let valuesWithFrequencies: [(T, Int)]
    fileprivate let frequentValues: [T]


    // MARK: - Initializers

    /// Creates a new FrequencyTable instance with values and their frequencies provided.
    ///
    /// - Parameters:
    ///     - values:             An array full of values to be saved into the frequency table.
    ///     - frequencyClosure:   The closure to specify the frequency for a specific value.
    public init(values: [T], frequencyClosure: (T) -> Int) {

        self.valuesWithFrequencies = values.map { ($0, frequencyClosure($0)) }
        self.frequentValues = Array(self.valuesWithFrequencies.map { (value, frequency) -> [T] in
            return (0..<frequency).map { _ in value }
        }.joined())

    }


    // MARK: - Instance Methods

    /// - Returns: A random value taking frequencies into account or nil if values empty.
    public func sample() -> T? {
        return frequentValues.sample()
    }

    /// Returns an array of random values taking frequencies into account or nil if values empty.
    ///
    /// - Parameters:
    ///     - size: The size of the resulting array of random values.
    ///
    /// - Returns: An array of random values or nil if values empty.
    public func sample(size: Int) -> [T]? {

        if !self.frequentValues.isEmpty {
            var sampleElements: [T] = []

            size.times {
                sampleElements.append(self.sample()!)
            }

            return sampleElements
        }

        return nil
    }


}
