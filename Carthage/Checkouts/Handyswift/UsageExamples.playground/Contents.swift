import UIKit
import HandySwift
import PlaygroundSupport

// Wait for all async calls
PlaygroundPage.current.needsIndefiniteExecution = true

//: # Globals
//: Some global helpers.

//: ### delay(bySeconds:) { ... }
//: Runs a given closure after a delay given in seconds. Dispatch queue can be set optionally.

var date = NSDate()
print("Without delay: \(date)")

delay(by: .milliseconds(1_500)) { 
    date = NSDate()
    print("Delayed by 1.5 seconds: \(date)")
}

delay(by: .seconds(5), qosClass: .userInteractive) { 
    date = NSDate()
    print("Delayed by 5 seconds: \(date)")

    // Finish up the run of the Playground
    PlaygroundPage.current.finishExecution()
}

//: # Extensions
//: Some extensions to existing Swift structures.

//: ## IntExtension
//: ### init(randomBelow:)
//: Initialize random Int value below given positive value.

Int(randomBelow: 50)
Int(randomBelow: 1_000_000)


//: ### n.times { someCode }
//: Calls someCode n times.

var stringArray: [String] = []

3.times{ stringArray.append("Hello World!") }
stringArray

//: ### n.timesMake { someCode }
//: Makes array by adding someCode's return value n times.

let intArray = 5.timesMake { Int(randomBelow: 1_000)! }

//: ## StringExtension
//: ### string.strip
//: Returns string with whitespace characters stripped from start and end.

" \n\t BB-8 likes Rey \t\n ".stripped()

//: ### string.isBlank
//: Checks if String contains any characters other than whitespace characters.

"".isEmpty
"".isBlank

"  \t  ".isEmpty
"  \t\n  ".isBlank

//: ### init(randomWithLength:allowedCharactersType:)
//: Get random numeric/alphabetic/alphanumeric String of given length.

String(randomWithLength: 4, allowedCharactersType: .numeric)
String(randomWithLength: 6, allowedCharactersType: .alphabetic)
String(randomWithLength: 8, allowedCharactersType: .alphaNumeric)
String(randomWithLength: 10, allowedCharactersType: .allCharactersIn("?!🐲🍏✈️🎎🍜"))


//: ## DictionaryExtension
//: ### init?(keys:values:)
//: Initializes a new `Dictionary` and fills it with keys and values arrays or returns nil if count of arrays differ.

let structure = ["firstName", "lastName"]
let dataEntries = [["Harry", "Potter"], ["Hermione", "Granger"], ["Ron", "Weasley"]]
Dictionary(keys: structure, values: dataEntries[0])

let structuredEntries = dataEntries.map{ Dictionary(keys: structure, values: $0) }
structuredEntries

Dictionary(keys: [1,2,3], values: [1,2,3,4,5])

//: ### .merge(Dictionary)
//: Merges a given `Dictionary` into an existing `Dictionary` overriding existing values for matching keys.

var dict = ["A": "A value", "B": "Old B value"]
dict.merge(["B": "New B value", "C": "C value"])

//: ### .mergedWith(Dictionary)
//: Create new merged `Dictionary` with the given `Dictionary` merged into a `Dictionary` overriding existing values for matching keys.

let immutableDict = ["A": "A value", "B": "Old B value"]
let mergedDict = immutableDict.merged(with: ["B": "New B value", "C": "C value"])
mergedDict

//: ## ArrayExtension
//: ### .sample
//: Returns a random element within the array or nil if array empty.

[1, 2, 3, 4, 5].sample
([] as [Int]).sample

//: ### .sample(size:)
//: Returns an array with `size` random elements or nil if array empty.

[1, 2, 3, 4, 5].sample(size: 3)
[1, 2, 3, 4, 5].sample(size: 12)
([] as [Int]).sample(size: 3)

//: ### .combinations(with:)
//: Combines each element with each element of a given other array.
[1, 2, 3].combinations(with: ["A", "B"])

//: ### .sort(stable:) / .sorted(stable:) / .sort(by:stable:) / .sorted(by:stable:)
//: Stable sorting methods to sort arrays without destroying pre-existing ordering for equal cases.

// Build an example class to demo two factors of ordering (a and b).
struct T: Equatable {
    let a: Int, b: Int

    static func == (lhs: T, rhs: T) -> Bool {
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
}

var unsortedArray = [T(a: 0, b: 2), T(a: 1, b: 2), T(a: 2, b: 2), T(a: 3, b: 1), T(a: 4, b: 1), T(a: 5, b: 0)]

//: Get sorted copy of array (not touching the original array).
unsortedArray.sorted(by: { lhs, rhs in lhs.b < rhs.b }, stable: true)
unsortedArray

//: Sort in place (mutating).
unsortedArray.sort(by: { lhs, rhs in lhs.b < rhs.b }, stable: true)
unsortedArray // now sorted

//: ## DispatchTimeIntervalExtension
//: ### .timeInterval
//: Returns a `TimeInterval` object from a `DispatchTimeInterval`.

DispatchTimeInterval.milliseconds(500).timeInterval

//: ## TimeIntervalExtension
//: ### Unit based pseudo-initializers
//: Returns a `TimeInterval` object with a given value in a the specified unit.

TimeInterval.days(1.5)
TimeInterval.hours(1.5)
TimeInterval.minutes(1.5)
TimeInterval.seconds(1.5)
TimeInterval.milliseconds(1.5)
TimeInterval.microseconds(1.5)
TimeInterval.nanoseconds(1.5)

//: ### Unit based getters
//: Returns a double value with the time interval converted to the specified unit.

let timeInterval: TimeInterval = 60 * 60 * 6

timeInterval.days
timeInterval.hours
timeInterval.minutes
timeInterval.seconds
timeInterval.milliseconds
timeInterval.microseconds
timeInterval.nanoseconds


//: # Added Structures
//: New structures added to extend the Swift standard library.
//: ## SortedArray
//: ### SortedArray(array: unsortedArray)
//: Initializes with unsorted array.

let sortedArray = SortedArray([5, 2, 1, 3, 0, 4])

//: ### sortedArray.array
//: Gives access to internal sorted array.

sortedArray.array

//: ### sortedArray.firstMatchingIndex{ predicate }
//: Binary search with predicate.

let index = sortedArray.index { $0 > 1 }
index

//: ### sortedArray.subArray(toIndex: index)
//: Returns beginning part as sorted subarray.

let nonMatchingSubArray = sortedArray.prefix(upTo: index!)
nonMatchingSubArray.array

//: ### sortedArray.subArray(fromIndex: index)
//: Returns ending part as sorted subarray.

let matchingSubArray = sortedArray.suffix(from: index!)
matchingSubArray.array


//: ## FrequencyTable
//: ### FrequencyTable(values: valuesArray){ /* frequencyClosure */ }
//: Initialize with values and closure.

struct WordFrequency {
    let word: String; let frequency: Int
    init(word: String, frequency: Int) { self.word = word; self.frequency = frequency }
}
let wordFrequencies = [
    WordFrequency(word: "Harry", frequency: 10),
    WordFrequency(word: "Hermione", frequency: 4),
    WordFrequency(word: "Ronald", frequency: 1)
]

let frequencyTable = FrequencyTable(values: wordFrequencies){ $0.frequency }
frequencyTable

//: ### .sample
//: Returns a random element with frequency-based probability within the array or nil if array empty.

frequencyTable.sample
let randomWord = frequencyTable.sample.map{ $0.word }
randomWord

//: ### .sample(size:)
//: Returns an array with `size` frequency-based random elements or nil if array empty.

frequencyTable.sample(size: 6)
let randomWords = frequencyTable.sample(size: 6)!.map{ $0.word }
randomWords
