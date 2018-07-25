//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

/// Data structure to keep a sorted array of elements for fast access.
public struct SortedArray<Element: Comparable> {
    // MARK: - Stored Instance Properties
    private var internalArray: [Element]

    /// Returns the sorted array of elements.
    public var array: [Element] { return self.internalArray }

    // MARK: - Initializers
    /// Creates a new, empty array.
    ///
    /// For example:
    ///
    ///     var emptyArray = SortedArray<Int>()
    public init() {
        internalArray = []
    }

    /// Creates a new SortedArray with a given sequence of elements and sorts its elements.
    ///
    /// - Complexity: The same as `sort()` on an Array –- probably O(n * log(n)).
    ///
    /// - Parameters:
    ///     - array: The array to be initially sorted and saved.
    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        self.init(sequence: sequence, preSorted: false)
    }

    private init<S: Sequence>(sequence: S, preSorted: Bool) where S.Iterator.Element == Element {
        internalArray = preSorted ? Array(sequence) : Array(sequence).sorted()
    }

    // MARK: - Instance Methods
    /// Returns the first index in which an element of the array satisfies the given predicate.
    /// Matching is done using binary search to minimize complexity.
    ///
    /// - Complexity: O(log(n))
    ///
    /// - Parameters:
    ///   - predicate: The predicate to match the elements against.
    /// - Returns: The index of the first matching element or `nil` if none of them matches.
    public func index(where predicate: (Element) -> Bool) -> Int? {
        // cover trivial cases
        guard !array.isEmpty else { return nil }
        if let first = array.first, predicate(first) { return array.startIndex } // swiftlint:disable:this if_as_guard
        if let last = array.last, !predicate(last) { return nil } // swiftlint:disable:this if_as_guard

        // binary search for first matching element
        var foundMatch = false
        var lowerIndex = array.startIndex
        var upperIndex = array.endIndex

        while lowerIndex != upperIndex {
            let middleIndex = lowerIndex + (upperIndex - lowerIndex) / 2
            guard predicate(array[middleIndex]) else { lowerIndex = middleIndex + 1; continue }

            upperIndex = middleIndex
            foundMatch = true
        }

        guard foundMatch else { return nil }
        return lowerIndex
    }

    /// Returns a sub array of a SortedArray up to a given index (excluding it) without resorting.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - index: The upper bound index until which to include elements.
    /// - Returns: A new SortedArray instance including all elements until the specified index (exluding it).
    public func prefix(upTo index: Int) -> SortedArray {
        let subarray = Array(array[array.indices.prefix(upTo: index)])
        return SortedArray(sequence: subarray, preSorted: true)
    }

    /// Returns a sub array of a SortedArray up to a given index (including it) without resorting.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - index: The upper bound index until which to include elements.
    /// - Returns: A new SortedArray instance including all elements until the specified index (including it).
    public func prefix(through index: Int) -> SortedArray {
        let subarray = Array(array[array.indices.prefix(through: index)])
        return SortedArray(sequence: subarray, preSorted: true)
    }

    /// Returns a sub array of a SortedArray starting at a given index without resorting.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - index: The lower bound index from which to start including elements.
    /// - Returns: A new SortedArray instance including all elements starting at the specified index.
    public func suffix(from index: Int) -> SortedArray {
        let subarray = Array(array[array.indices.suffix(from: index)])
        return SortedArray(sequence: subarray, preSorted: true)
    }

    /// Accesses a contiguous subrange of the SortedArray's elements.
    ///
    /// - Parameter
    ///   - bounds: A range of the SortedArray's indices. The bounds of the range must be valid indices.
    public subscript(bounds: Range<Int>) -> SortedArray {
        return SortedArray(sequence: array[bounds], preSorted: true)
    }

    // MARK: - Mutating Methods
    /// Adds a new item to the sorted array.
    ///
    /// - Complexity: O(log(n))
    ///
    /// - Parameters:
    ///   - newElement: The new element to be inserted into the array.
    public mutating func insert(newElement: Element) {
        let insertIndex = internalArray.index { $0 >= newElement } ?? internalArray.endIndex
        internalArray.insert(newElement, at: insertIndex)
    }

    /// Adds the contents of a sequence to the SortedArray.
    ///
    /// - Complexity: O(n * log(n))
    ///
    /// - Parameters:
    ///   - sequence
    public mutating func insert<S: Sequence>(contentsOf sequence: S) where S.Iterator.Element == Element {
        sequence.forEach { insert(newElement: $0) }
    }

    /// Removes an item from the sorted array.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - index: The index of the element to remove from the sorted array.
    public mutating func remove(at index: Int) {
        internalArray.remove(at: index)
    }
}
