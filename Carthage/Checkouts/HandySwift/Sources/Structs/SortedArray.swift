//
//  SortedArray.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

/// Data structure to keep a sorted array of elements for fast access.
public struct SortedArray<Element: Comparable> {
    
    // MARK: - Stored Instance Properties
    
    private var internalArray: Array<Element> = []
    
    /// Returns the sorted array of elements.
    public var array: Array<Element> {
        return self.internalArray
    }
    
    
    // MARK: - Initializers
    
    /// Creates a new SortedArray with a given array of elements and sorts the elements.
    ///
    /// - Complexity: Probably O(n * log(n)) -- complexity of `sort()` on an Array.
    ///
    /// - Parameters:
    ///     - array: The array to be initially sorted and saved.
    public init(array: [Element]) {
        self.init(array: array, preSorted: false)
    }
    
    private init(array: [Element], preSorted: Bool) {
        if preSorted {
            self.internalArray = array
        } else {
            self.internalArray = array.sort()
        }
    }
    
    
    // MARK: - Instance Methods
    
    /// Returns the index of the left most matching element. Matching is done via binary search.
    /// 
    /// - Complexity: O(log(n))
    ///
    /// - Parameters:
    ///   - predicate: The boolean predicate to match the elements with.
    /// - Returns: The index of the left most matching element.
    public func firstMatchingIndex(predicate: Element -> Bool) -> Array<Element>.Index? {
        
        // check if all elements match
        if let firstElement = self.array.first {
            if predicate(firstElement) {
                return self.array.startIndex
            }
        }
        
        // check if no element matches
        if let lastElement = self.array.last {
            if !predicate(lastElement) {
                return nil
            }
        }
        
        // binary search for first matching element
        var predicateMatched = false
        
        var lowerIndex = self.array.startIndex
        var upperIndex = self.array.endIndex
        
        while lowerIndex != upperIndex {
            
            let middleIndex = lowerIndex.advancedBy(lowerIndex.distanceTo(upperIndex) / 2)
            
            if predicate(self.array[middleIndex]) {
                upperIndex = middleIndex
                predicateMatched = true
            } else {
                lowerIndex = middleIndex.advancedBy(1)
            }
            
        }
        
        if !predicateMatched {
            return nil
        }
        
        return lowerIndex
    }
    
    /// Returns a sub array of a SortedArray to a given index without resorting.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - toIndex: The upper bound index until which to include elements.
    /// - Returns: A new SortedArray instance including all elements until the specified index.
    public func subArray(toIndex endIndex: Array<Element>.Index) -> SortedArray {
        
        let range = self.array.startIndex..<endIndex
        let subArray = Array(self.array[range])
        
        return SortedArray(array: subArray, preSorted: true)
        
    }
    
    /// Returns a sub array of a SortedArray starting at a given index without resorting.
    ///
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - toIndex: The lower bound index from which to start including elements.
    /// - Returns: A new SortedArray instance including all elements starting at the specified index.
    public func subArray(fromIndex startIndex: Array<Element>.Index) -> SortedArray {
        
        let range = startIndex..<self.array.endIndex
        let subArray = Array(self.array[range])
        
        return SortedArray(array: subArray, preSorted: true)
        
    }
    
    /// Removes an item from the sorted array.
    /// 
    /// - Complexity: O(1)
    ///
    /// - Parameters:
    ///   - atIndex: The index of the element to remove from the sorted array.
    public mutating func remove(atIndex index: Array<Element>.Index) {
        self.internalArray.removeAtIndex(index)
    }
    
}
