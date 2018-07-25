//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

extension Array {
    /// Returns a random element from the `Array`.
    ///
    /// - Returns: A random element from the array or `nil` if empty.
    public var sample: Element? {
        guard let randomIndex = Int(randomBelow: count) else { return nil }
        return self[randomIndex]
    }

    /// Returns a given number of random elements from the `Array`.
    ///
    /// - Parameters:
    ///   - size: The number of random elements wanted.
    /// - Returns: An array with the given number of random elements or `nil` if empty.
    public func sample(size: Int) -> [Element]? {
        guard !isEmpty else { return nil }

        var sampleElements: [Element] = []
        size.times { sampleElements.append(sample!) }

        return sampleElements
    }

    /// Combines each element with each element of a given array.
    ///
    /// Also known as: Cartesian product.
    ///
    /// - Parameters:
    ///   - other: Other array to combine the elements with.
    /// - Returns: An array of tuples with the elements of both arrays combined.
    public func combinations<T>(with other: [T]) -> [(Element, T)] {
        var combinations = [(Element, T)]()
        forEach { elem in other.forEach { otherElem in combinations.append((elem, otherElem)) } }

        return combinations
    }

    /// Sorts the collection in place by the order specified in the closure.
    ///
    /// NOTE: The default `sort` method is not stable, this one allows to explicitly specify it to be stable.
    ///
    /// - Parameters:
    ///   - stable: Speifies if the sorting algorithm should be stable.
    ///   - areInIncreasingOrder: The closure to specify the order of the elements to be sorted by.
    public mutating func sort(by areInIncreasingOrder: @escaping (Element, Element) -> Bool, stable: Bool) {
        guard stable else { sort(by: areInIncreasingOrder); return }
        stableMergeSort(by: areInIncreasingOrder)
    }

    /// Returns the elements of the sequence, sorted.
    ///
    /// NOTE: The default `sorted` method is not stable, this one allows to explicitly specify it to be stable.
    ///
    /// - Parameters:
    ///   - stable: Speifies if the sorting algorithm should be stable.
    ///   - areInIncreasingOrder: The closure to specify the order of the elements to be sorted by.
    public func sorted(by areInIncreasingOrder: @escaping (Element, Element) -> Bool, stable: Bool) -> [Element] {
        guard stable else { return sorted(by: areInIncreasingOrder) }

        var copy = [Element](self)
        copy.stableMergeSort(by: areInIncreasingOrder)

        return copy
    }

    /// Sorts the array in-place using a stable merge sort algorithm.
    mutating func stableMergeSort(by areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        var tmp = [Element]()
        tmp.reserveCapacity(numericCast(count))

        func merge(low: Int, mid: Int, high: Int) {
            tmp.removeAll(keepingCapacity: true)
            tmp.append(contentsOf: self[low..<high])

            var i = 0, j = mid - low // swiftlint:disable:this identifier_name
            let iMax = j, jMax = tmp.count

            for k in low..<high { // swiftlint:disable:this identifier_name
                let tmpPosIsJ = i == iMax || (j != jMax && areInIncreasingOrder(tmp[j], tmp[i]))
                self[k] = tmp[tmpPosIsJ ? j : i]

                if tmpPosIsJ {
                    j += 1
                } else {
                    i += 1
                }
            }
        }

        let n = count // swiftlint:disable:this identifier_name
        var size = 1
        while size < n {
            var low = 0

            while low < n - size {
                merge(low: low, mid: low + size, high: Swift.min(low + size * 2, n))
                low += size * 2
            }

            size *= 2
        }
    }
}

extension Array where Element: Comparable {
    /// Sorts the collection in place by the order specified in the closure.
    ///
    /// NOTE: The default `sort` method is not stable, this one allows to explicitly specify it to be stable.
    ///
    /// - Parameters:
    ///   - stable: Speifies if the sorting algorithm should be stable.
    public mutating func sort(stable: Bool) {
        sort(by: { lhs, rhs in  lhs < rhs }, stable: stable)
    }

    /// Returns the elements of the sequence, sorted.
    ///
    /// NOTE: The default `sorted` method is not stable, this one allows to explicitly specify it to be stable.
    ///
    /// - Parameters:
    ///   - stable: Speifies if the sorting algorithm should be stable.
    public func sorted(stable: Bool) -> [Element] {
        return sorted(by: { lhs, rhs in lhs < rhs }, stable: stable)
    }
}
