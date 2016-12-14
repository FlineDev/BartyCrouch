import UIKit
import HandySwift
import XCPlayground

// Wait for all async calls
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: # Globals
//: Some global helpers.

//: ### delay(bySeconds:) { ... }
//: Runs a given closure after a delay given in seconds. Dispatch queue can be set optionally.

var date = NSDate()
print("Without delay: \(date)")

delay(bySeconds: 1.5) {
    date = NSDate()
    print("Delayed by 1.5 seconds: \(date)")
}

delay(bySeconds: 5, dispatchLevel: .userInteractive) {
    date = NSDate()
    print("Delayed by 5 seconds: \(date)")

    // Finish up the run of the Playground
    XCPlaygroundPage.currentPage.finishExecution()
}

//: # Extensions
//: Some extensions to existing Swift structures.

//: ## IntExtension
//: ### init(randomBelow:)
//: Initialize random Int value below given positive value.

Int(randomBelow: 50)
Int(randomBelow: 1_000_000)


//: ## IntegerTypeExtension
//: ### n.times{ someCode }
//: Calls someCode n times.

var stringArray: [String] = []

3.times{ stringArray.append("Hello World!") }
stringArray

var intArray: [Int] = []
5.times {
    let randomInt = Int(randomBelow: 1_000)
    intArray.append(randomInt)
}
intArray


//: ## StringExtension
//: ### string.strip
//: Returns string with whitespace characters stripped from start and end.

" \t BB-8 likes Rey \t ".strip

//: ### string.isBlank
//: Checks if String contains any characters other than whitespace characters.

"".isEmpty
"".isBlank

"  \t  ".isEmpty
"  \t  ".isBlank

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
let mergedDict = immutableDict.mergedWith(["B": "New B value", "C": "C value"])
mergedDict

//: ## ArrayExtension
//: ### .sample
//: Returns a random element within the array or nil if array empty.

[1, 2, 3, 4, 5].sample()
([] as [Int]).sample()

//: ### .sample(size:)
//: Returns an array with `size` random elements or nil if array empty.

[1, 2, 3, 4, 5].sample(size: 3)
[1, 2, 3, 4, 5].sample(size: 12)
([] as [Int]).sample(size: 3)


//: ## ColorExtension (iOS & tvOS only)
//: ### .rgba
//: Returns a tuple with named RGBA parameters for easy access.

let rgbaColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
rgbaColor.rgba.red
rgbaColor.rgba.green
rgbaColor.rgba.blue
rgbaColor.rgba.alpha


//: ### .hsba
//: Returns a tuple with named HSBA parameters for easy access.

let hsbaColor = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 0.4)
hsbaColor.hsba.hue
hsbaColor.hsba.saturation
hsbaColor.hsba.brightness
hsbaColor.hsba.alpha

//: ### .change(ChangeableAttribute, by:)
//: Creates a new `UIColor` object with a single attribute changed by a given difference using addition.

rgbaColor.rgba.blue
let newRgbaColor = rgbaColor.change(.blue, by: 0.2)
newRgbaColor.rgba.blue

//: ### .change(ChangeableAttribute, to:)
//: Creates a new `UIColor` object with the value of a single attribute set to a given value.

hsbaColor.hsba.brightness
let newHsbaColor = hsbaColor.change(.brightness, to: 0.8)
newHsbaColor.hsba.brightness

//: ## CoreGraphicsExtensions
//: ### CGSize.inPixels / CGSize.inPixels(screen:)
//: Returns a new CGSize object with the width and height converted to true pixels on screen.

let size = CGSize(width: 100, height: 50)
size.inPixels // test this with a Retina screen target
size.inPixels(UIScreen.screens.last!) // pass a different screen

//: ### CGPoint.inPixels / CGPoint.inPixels(screen:)
//: Returns a new CGPoint object with the x and y converted to true pixels on screen.

let point = CGPoint(x: 100, y: 50)
point.inPixels // test this with a Retina screen target
point.inPixels(UIScreen.screens.last!) // pass a different screen

//: ### CGRect.inPixels / CGRect.inPixels(screen:)
//: Returns a new CGRect object with the origin and size converted to true pixels on screen.

let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
rect.inPixels // test this with a Retina screen target
rect.inPixels(UIScreen.screens.last!) // pass a different screen

//: ### CGRect.init(size:) / CGRect.init(width:height:)
//: Creates a new CGRect object from origin zero with given size.

let someSize = CGSize(width: 100, height: 50)

let originZeroRect1 = CGRect(size: someSize)
let originZeroRect2 = CGRect(width: 100, height: 50)

//: # Added Structures
//: New structures added to extend the Swift standard library.
//: ## SortedArray
//: ### SortedArray(array: unsortedArray)
//: Initializes with unsorted array.

let sortedArray = SortedArray(array: [5, 2, 1, 3, 0, 4])

//: ### sortedArray.array
//: Gives access to internal sorted array.

sortedArray.array

//: ### sortedArray.firstMatchingIndex{ predicate }
//: Binary search with predicate.

let index = sortedArray.firstMatchingIndex{ $0 > 1 }
index

//: ### sortedArray.subArray(toIndex: index)
//: Returns beginning part as sorted subarray.

let nonMatchingSubArray = sortedArray.subArray(toIndex: index!)
nonMatchingSubArray.array

//: ### sortedArray.subArray(fromIndex: index)
//: Returns ending part as sorted subarray.

let matchingSubArray = sortedArray.subArray(fromIndex: index!)
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

frequencyTable.sample()
let randomWord = frequencyTable.sample().map{ $0.word }
randomWord

//: ### .sample(size:)
//: Returns an array with `size` frequency-based random elements or nil if array empty.

frequencyTable.sample(size: 6)
let randomWords = frequencyTable.sample(size: 6)!.map{ $0.word }
randomWords
