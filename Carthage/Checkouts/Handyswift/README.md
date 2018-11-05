<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/HandySwift/stable/Logo.png"
      width=600>
</p>

<p align="center">
    <a href="https://app.bitrise.io/app/cbc4cab821708298">
        <img src="https://app.bitrise.io/app/cbc4cab821708298/status.svg?token=1fWFE7UCuTBoYTGf4StnFQ&branch=stable"
             alt="Build Status">
    </a>
    <a href="https://codebeat.co/projects/github-com-flinesoft-handyswift">
        <img src="https://codebeat.co/badges/283e545d-02e9-4fcf-aabc-40cacfbfe26c"
             alt="Codebeat Status">
    </a>
    <a href="https://github.com/Flinesoft/HandySwift/releases">
        <img src="https://img.shields.io/badge/Version-2.7.0-blue.svg"
             alt="Version: 2.7.0">
    </a>
    <img src="https://img.shields.io/badge/Swift-4.2-FFAC45.svg"
         alt="Swift: 4.2">
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20Linux-FF69B4.svg"
        alt="Platforms: iOS | tvOS | macOS | Linux">
    <a href="https://github.com/Flinesoft/HandySwift/blob/stable/LICENSE.md">
        <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg"
              alt="License: MIT">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="https://github.com/Flinesoft/HandySwift/issues">Issues</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#license">License</a>
</p>


# HandySwift

The goal of this library is to **provide handy features** that didn't make it to the Swift standard library (yet) due to many different reasons. Those could be that the Swift community wants to keep the standard library clean and manageable or simply hasn't finished discussion on a specific feature yet.

If you like this, please also checkout [HandyUIKit](https://github.com/Flinesoft/HandyUIKit) for handy UI features that we feel should have been part of the UIKit frameworks in the first place.

> If you are **upgrading from a previous major version** of HandySwift (e.g. 1.x to 2.x) then checkout the [releases section on GitHub](https://github.com/Flinesoft/HandySwift/releases) and look out for the release notes of the last major releas(es) (e.g. 2.0.0) for an overview of the changes made. It'll save you time as hints are on how best to migrate are included there.

## Installation

Currently the recommended way of installing this library is via [Carthage](https://github.com/Carthage/Carthage) on macOS or [Swift Package Manager](https://github.com/apple/swift-package-manager) on Linux. [Cocoapods](https://github.com/CocoaPods/CocoaPods) might work, too, but is not tested.

You can of course also just include this framework manually into your project by downloading it or by using git submodules.

## Usage

Please have a look at the UsageExamples.playground for a complete list of features provided.
Open the Playground from within the `.xcworkspace` in order for it to work.

---
#### Feature Overview

- [Globals](#globals)
- Extensions
  - [IntExtension](#intextension)
  - [IntegerTypeExtension](#integertypeextension)
  - [StringExtension](#stringextension)
  - [CollectionExtension](#collectionextension)
  - [ArrayExtension](#arrayextension)
  - [DictionaryExtension](#dictionaryextension)
  - [DispatchTimeIntervalExtension](#dispatchtimeintervalextension)
- New types
  - [SortedArray](#sortedarray)
  - [FrequencyTable](#frequencytable)
  - [Regex](#regex)
  - [Weak](#weak)
  - [Unowned](#unowned)

---

### Globals
Some global helpers.

#### delay(bySeconds:) { ... }
Runs a given closure after a delay given in seconds. Dispatch queue can be set optionally, defaults to Main thread.

``` Swift
delay(by: .milliseconds(1_500)) { // Runs in Main thread by default
    date = NSDate() // Delayed by 1.5 seconds: 2016-06-07 05:38:05 +0000
}
delay(by: .seconds(5), dispatchLevel: .userInteractive) {
    date = NSDate() // Delayed by 5 seconds: 2016-06-07 05:38:08 +0000
}
```

### IntExtension

#### init(randomBelow:)

Initialize random Int value below given positive value.

``` Swift
Int(randomBelow: 50)! // => 26
Int(randomBelow: 1_000_000)! // => 208041
```

#### .times

Repeat some code block a given number of times.

``` Swift
3.times { print("Hello World!") }
// => prints "Hello World!" 3 times
```

#### .timesMake

Makes array by adding closure's return value n times.

``` Swift
let intArray = 5.timesMake { Int(randomBelow: 1_000)! }
// => [481, 16, 680, 87, 912]
```

### StringExtension

#### .stripped()

Returns string with whitespace characters stripped from start and end.

``` Swift
" \n\t BB-8 likes Rey \t\n ".stripped()
// => "BB-8 likes Rey"
```

#### .isBlank

Checks if String contains any characters other than whitespace characters.

``` Swift
"  \t  ".isBlank
// => true
```

#### init(randomWithLength:allowedCharactersType:)

Get random numeric/alphabetic/alphanumeric String of given length.

``` Swift
String(randomWithLength: 4, allowedCharactersType: .numeric) // => "8503"
String(randomWithLength: 6, allowedCharactersType: .alphabetic) // => "ysTUzU"
String(randomWithLength: 8, allowedCharactersType: .alphaNumeric) // => "2TgM5sUG"
String(randomWithLength: 10, allowedCharactersType: .allCharactersIn("?!🐲🍏✈️🎎🍜"))
// => "!🍏🐲✈️🎎🐲🍜??🍜"
```

### ArrayExtension

#### .sample

Returns a random element within the array or nil if array empty.

``` Swift
[1, 2, 3, 4, 5].sample // => 4
([] as [Int]).sample // => nil
```

#### .sample(size:)

Returns an array with `size` random elements or nil if array empty.

``` Swift
[1, 2, 3, 4, 5].sample(size: 3) // => [2, 1, 4]
[1, 2, 3, 4, 5].sample(size: 8) // => [1, 4, 2, 4, 3, 4, 1, 5]
([] as [Int]).sample(size: 3) // => nil
```

#### .combinations(with:)

Combines each element with each element of a given other array.

``` Swift
[1, 2, 3].combinations(with: ["A", "B"])
// => [(1, "A"), (1, "B"), (2, "A"), (2, "B"), (3, "A"), (3, "B")]
```

### DictionaryExtension
#### init?(keys:values:)

Initializes a new `Dictionary` and fills it with keys and values arrays or returns nil if count of arrays differ.

``` Swift
let structure = ["firstName", "lastName"]
let dataEntries = [["Harry", "Potter"], ["Hermione", "Granger"], ["Ron", "Weasley"]]
Dictionary(keys: structure, values: dataEntries[0]) // => ["firstName": "Harry", "lastName": "Potter"]

dataEntries.map{ Dictionary(keys: structure, values: $0) }
// => [["firstName": "Harry", "lastName": "Potter"], ["firstName": "Hermione", "lastName": "Grange"], ...]

Dictionary(keys: [1,2,3], values: [1,2,3,4,5]) // => nil
```

#### .merge(Dictionary)

Merges a given `Dictionary` into an existing `Dictionary` overriding existing values for matching keys.

``` Swift
var dict = ["A": "A value", "B": "Old B value"]
dict.merge(["B": "New B value", "C": "C value"])
dict // => ["A": "A value", "B": "New B value", "C": "C value"]
```

#### .merged(with: Dictionary)
Create new merged `Dictionary` with the given `Dictionary` merged into a `Dictionary` overriding existing values for matching keys.

``` Swift
let immutableDict = ["A": "A value", "B": "Old B value"]
immutableDict.merged(with: ["B": "New B value", "C": "C value"])
// => ["A": "A value", "B": "New B value", "C": "C value"]
```

### DispatchTimeIntervalExtension
#### .timeInterval

Returns a `TimeInterval` object from a `DispatchTimeInterval`.

``` Swift
DispatchTimeInterval.milliseconds(500).timeInterval // => 0.5
```

### TimeIntervalExtension
#### Unit based pseudo-initializers
Returns a `TimeInterval` object with a given value in a the specified unit.

``` Swift
TimeInterval.days(1.5) // => 129600
TimeInterval.hours(1.5) // => 5400
TimeInterval.minutes(1.5) // => 90
TimeInterval.seconds(1.5) // => 1.5
TimeInterval.milliseconds(1.5) // => 0.0015
TimeInterval.microseconds(1.5) // => 1.5e-06
TimeInterval.nanoseconds(1.5) // => 1.5e-09
```

#### Unit based getters
Returns a double value with the time interval converted to the specified unit.

``` Swift
let timeInterval: TimeInterval = 60 * 60 * 6

timeInterval.days // => 0.25
timeInterval.hours // => 6
timeInterval.minutes // => 360
timeInterval.seconds // => 21600
timeInterval.milliseconds // => 21600000
timeInterval.microseconds // => 21600000000
timeInterval.nanoseconds // => 21600000000000
```


### SortedArray

The main purpose of this wrapper is to provide speed improvements for specific actions on sorted arrays.

#### init(array:) & .array

``` Swift
let unsortedArray = [5, 2, 1, 3, 0, 4]
let sortedArray = SortedArray(unsortedArray)
sortedArray.array   // => [0, 1, 2, 3, 4, 5]
```

#### .index

Finds the lowest index matching the given predicate using binary search for an improved performance (`O(log n)`).

``` Swift
SortedArray([5, 2, 1, 3, 0, 4]).index { $0 > 1 }
// => 2
```

#### .prefix(upTo:) / .prefix(through:)

``` Swift
SortedArray([5, 2, 1, 3, 0, 4]).prefix(upTo: 2)
// => [0, 1]
```

#### .suffix(from:)

``` Swift
SortedArray([5, 2, 1, 3, 0, 4]).suffix(from: 2)
// => [2, 3, 4, 5]
```

### FrequencyTable

#### FrequencyTable(values: valuesArray) { valueToFrequencyClosure }

Initialize with values and closure.

``` Swift
struct WordFrequency {
    let word: String; let frequency: Int
    init(word: String, frequency: Int) { self.word = word; self.frequency = frequency }
}
let wordFrequencies = [
    WordFrequency(word: "Harry", frequency: 10),
    WordFrequency(word: "Hermione", frequency: 4),
    WordFrequency(word: "Ronald", frequency: 1)
]

let frequencyTable = FrequencyTable(values: wordFrequencies) { $0.frequency }
// => HandySwift.FrequencyTable<WordFrequency>
```

#### .sample

Returns a random element with frequency-based probability within the array or nil if array empty.

``` Swift
frequencyTable.sample
let randomWord = frequencyTable.sample.map{ $0.word }
// => "Harry"
```

#### .sample(size:)

Returns an array with `size` frequency-based random elements or nil if array empty.

``` Swift
frequencyTable.sample(size: 6)
let randomWords = frequencyTable.sample(size: 6)!.map{ $0.word }
// => ["Harry", "Ronald", "Harry", "Harry", "Hermione", "Hermione"]
```


### Regex

`Regex` is a swifty regex engine built on top of the `NSRegularExpression` API.

#### init(_:options:)

Initialize with pattern and, optionally, options.

``` swift
let regex = try Regex("(Phil|John), [\\d]{4}")

let options: Regex.Options = [.ignoreCase, .anchorsMatchLines, .dotMatchesLineSeparators, .ignoreMetacharacters]
let regexWithOptions = try Regex("(Phil|John), [\\d]{4}", options: options)
```

#### regex.matches(_:)

Checks whether regex matches string

``` swift
regex.matches("Phil, 1991") // => true
````

#### regex.matches(in:)

Returns all matches

``` swift
regex.matches(in: "Phil, 1991 and John, 1985")  
// => [Match<"Phil, 1991">, Match<"John, 1985">]
```

#### regex.firstMatch(in:)

Returns first match if any

``` swift
regex.firstMatch(in: "Phil, 1991 and John, 1985")
// => Match<"Phil, 1991">
```

#### regex.replacingMatches(in:with:count:)

Replaces all matches in a string with a template string, up to the a maximum of matches (count).

``` swift
regex.replacingMatches(in: "Phil, 1991 and John, 1985", with: "$1 was born in $2", count: 2)
// => "Phil was born in 1991 and John was born in 1985"
```

#### match.string

Returns the captured string

``` swift
match.string // => "Phil, 1991"
```

#### match.range

Returns the range of the captured string within the base string

``` swift
match.range // => Range
```

#### match.captures

Returns the capture groups of a match

``` swift
match.captures // => ["Phil", "1991"]
```

#### match.string(applyingTemplate:)

Replaces the matched string with a template string

``` swift
match.string(applyingTemplate: "$1 was born in $2")
// => "Phil was born in 1991"
```

### Weak

`Weak` is a wrapper to store weak references to a `Wrapped` instance.

#### Weak(_:)

Initialize with an object reference.

``` swift
let text: NSString = "Hello World!"
var weak = Weak(text)
```

#### Accessing inner Reference

Access the inner wrapped reference with the `value` property.

``` swift
print(weak.value!)
```

#### NilLiteralExpressible Conformance

Create a `Weak` wrapper by assigning nil to the value.
``` swift
var weakWrappedValue: Weak<AnyObject> = nil
```

### Unowned

`Unowned` is a wrapper to store unowned references to a `Wrapped` instance.

#### Unowned(_:)

Initialize with an object reference.
``` swift
var unowned = Unowned(text)
```

#### Accessing inner Reference

Access the inner wrapped reference with the `value` property.
``` swift
print(unowned.value)
```

### CollectionExtension

#### [try:]

Returns an element with the specified index or nil if the element does not exist .
``` swift
let testArray = [0, 1, 2, 3, 20]
testArray[try: 4]  // => Optional(20)
testArray[try: 20] // => nil
```


## Contributing

See the file [CONTRIBUTING.md](https://github.com/Flinesoft/HandySwift/blob/stable/CONTRIBUTING.md).


## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
