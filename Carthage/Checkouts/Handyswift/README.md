<p align="center">
    <img src="https://raw.githubusercontent.com/Flinesoft/HandySwift/stable/Logo.png"
      width=600 height=167>
</p>

<p align="center">
    <a href="https://www.bitrise.io/app/810d996d77fb0abf">
        <img src="https://www.bitrise.io/app/810d996d77fb0abf.svg?token=kr27kfE1r8jE0qdtpXgIzw&branch=stable"
             alt="Build Status">
    </a>
    <a href="https://codebeat.co/projects/github-com-flinesoft-handyswift">
        <img src="https://codebeat.co/badges/283e545d-02e9-4fcf-aabc-40cacfbfe26c"
             alt="codebeat badge">
    </a>
    <a href="https://github.com/Flinesoft/HandySwift/releases">
        <img src="https://img.shields.io/badge/Version-1.4.1%20|%201.2.0-blue.svg"
             alt="Version: 1.4.1 | 1.2.0">
    </a>
    <img src="https://img.shields.io/badge/Swift-3.0%20|%202.3%20|%202.2-FFAC45.svg"
         alt="Swift: 3.0 | 2.3 | 2.2">
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20tvOS%20%7C%20OS%20X-FF69B4.svg"
        alt="Platforms: iOS | tvOS | OS X">
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

The goal of this library is to provide handy features that didn't make it to the Swift standard library (yet) due to many different reasons. Those could be that the Swift community wants to keep the standard library clean and manageable or simply hasn't finished discussion on a specific feature yet.

## Installation

Currently the recommended way of installing this library is via [Carthage](https://github.com/Carthage/Carthage).
[Cocoapods](https://github.com/CocoaPods/CocoaPods) is supported, too.
[Swift Package Manager](https://github.com/apple/swift-package-manager) was targeted but didn't work in my tests.

You can of course also just include this framework manually into your project by downloading it or by using git submodules.

### Carthage

Depending on the Swift version of your project, place one of the following lines to your Cartfile:

**Swift 3:**

``` Swift
github "Flinesoft/HandySwift"
```

**Swift 2.3:**

``` Swift
github "Flinesoft/HandySwift" "support/swift2.3"
```

**Swift 2.2:**

``` Swift
github "Flinesoft/HandySwift" == 1.2.0
```

Now run `carthage update`. Then drag & drop the HandySwift.framework in the Carthage/build folder to your project. Now you can `import HandySwift` in each class you want to use its features. Refer to the [Carthage README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for detailed / updated instructions.

### CocoaPods

Add the line `pod 'HandySwift'` to your target in your `Podfile` and make sure to include `use_frameworks!`
at the top. The result might look similar to this:

``` Ruby
platform :ios, '8.0'
use_frameworks!

target 'MyAppTarget' do
    pod 'HandySwift', '~> 1.0'
end
```

Now close your project and run `pod install` from the command line. Then open the `.xcworkspace` from within your project folder.
Build your project once (with `Cmd+B`) to update the frameworks known to Xcode. Now you can `import HandySwift` in each class you want to use its features.
Refer to [CocoaPods.org](https://cocoapods.org) for detailed / updates instructions.

## Usage

Please have a look at the UsageExamples.playground for a complete list of features provided.
Open the Playground from within the `.xcworkspace` in order for it to work.

### Globals
Some global helpers.

#### delay(bySeconds:) { ... }
Runs a given closure after a delay given in seconds. Dispatch queue can be set optionally, defaults to Main thread.

``` Swift
var date = NSDate() // Without delay: 2016-06-07 05:38:03 +0000
delay(bySeconds: 1.5) { // Runs in Main thread by default
    date = NSDate() // Delayed by 1.5 seconds: 2016-06-07 05:38:05 +0000
}
delay(bySeconds: 5, dispatchLevel: .userInteractive) {
    date = NSDate() // Delayed by 5 seconds: 2016-06-07 05:38:08 +0000
}
```

### IntExtension

#### init(randomBelow:)

Initialize random Int value below given positive value.

``` Swift
Int(randomBelow: 50) // => 26
Int(randomBelow: 1_000_000) // => 208041
```

### IntegerTypeExtension

#### .times

Repeat some code block a given number of times.

``` Swift
3.times { array.append("Hello World!") }
// => ["Hello World!", "Hello World!", "Hello World!"]

5.times {
  let randomInt = Int(randomBelow: 1_000)
  intArray.append(randomInt)
}
// => [481, 16, 680, 87, 912]
```

### StringExtension

#### .strip

Returns string with whitespace characters stripped from start and end.

``` Swift
" \n\t BB-8 likes Rey \t\n ".strip
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
[1, 2, 3, 4, 5].sample() // => 4
([] as [Int]).sample() // => nil
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

#### .mergedWith(Dictionary)
Create new merged `Dictionary` with the given `Dictionary` merged into a `Dictionary` overriding existing values for matching keys.

``` Swift
let immutableDict = ["A": "A value", "B": "Old B value"]
immutableDict.mergedWith(["B": "New B value", "C": "C value"])
// => ["A": "A value", "B": "New B value", "C": "C value"]
```

### ColorExtension (iOS & tvOS only)

#### .rgba
Returns a tuple with named RGBA parameters for easy access.

``` Swift
let rgbaColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.4)
rgbaColor.rgba.red // => 0.1
rgbaColor.rgba.green // => 0.2
rgbaColor.rgba.blue // => 0.3
rgbaColor.rgba.alpha // => 0.4
```

#### .hsba
Returns a tuple with named HSBA parameters for easy access.

``` Swift
let hsbaColor = UIColor(hue: 0.1, saturation: 0.2, brightness: 0.3, alpha: 0.4)
hsbaColor.hsba.hue // => 0.1
hsbaColor.hsba.saturation // => 0.2
hsbaColor.hsba.brightness // => 0.3
hsbaColor.hsba.alpha // => 0.4
```

#### .change(ChangeableAttribute, by:)
Creates a new `UIColor` object with a single attribute changed by a given difference using addition.

``` Swift
rgbaColor.rgba.blue // => 0.3
let newRgbaColor = rgbaColor.change(.blue, by: 0.2)
newRgbaColor.rgba.blue // => 0.5
```

#### .change(ChangeableAttribute, to:)
Creates a new `UIColor` object with the value of a single attribute set to a given value.

``` Swift
hsbaColor.hsba.brightness // => 0.3
let newHsbaColor = hsbaColor.change(.brightness, to: 0.8)
newHsbaColor.hsba.brightness // => 0.8
```

### CoreGraphicsExtensions (partly iOS & tvOS only)

#### CGSize.inPixels / CGSize.inPixels(screen:)
Returns a new CGSize object with the width and height converted to true pixels on screen.

``` Swift
let size = CGSize(width: 100, height: 50)
size.inPixels // test this with a Retina screen target
// => {w 200 h 100}
size.inPixels(UIScreen.screens.last!) // pass a different screen
// => {w 50 h 25}
```

#### CGPoint.inPixels / CGPoint.inPixels(screen:)
Returns a new CGPoint object with the x and y converted to true pixels on screen.

``` Swift
let point = CGPoint(x: 100, y: 50)
point.inPixels // test this with a Retina screen target
// => {x 200 y 100}
let someScreen = UIScreen.screens.last!
point.inPixels(someScreen) // pass a different screen
// => {x 50 y 25}
```

#### CGRect.inPixels / CGRect.inPixels(screen:)
Returns a new CGRect object with the origin and size converted to true pixels on screen.

``` Swift
let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
rect.inPixels // test this with a Retina screen target
// => {x 20 y 40 w 200 h 100}
let someScreen = UIScreen.screens.last!
rect.inPixels(someScreen) // pass a different screen
// => {x 5 y 10 w 50 h 25}
```

#### CGRect.init(size:) / CGRect.init(width:height:)
Creates a new CGRect object from origin zero with given size.

``` Swift
let someSize = CGSize(width: 100, height: 50)

let originZeroRect1 = CGRect(size: someSize)
let originZeroRect2 = CGRect(width: 100, height: 50)
```

### SortedArray

The main purpose of this wrapper is to provide speed improvements for specific actions on sorted arrays.

#### init(array:) & .array

``` Swift
let unsortedArray = [5, 2, 1, 3, 0, 4]
let sortedArray = SortedArray(array: unsortedArray)
sortedArray.array   // => [0, 1, 2, 3, 4, 5]
```

#### .firstMatchingIndex

Finds the lowest index matching the given predicate using binary search for an improved performance (`O(log n)`).

``` Swift
SortedArray(array: [5, 2, 1, 3, 0, 4]).firstMatchingIndex{ $0 > 1 }
// => 2
```

#### .subArray(toIndex:)

``` Swift
SortedArray(array: [5, 2, 1, 3, 0, 4]).subArray(toIndex: Array<Int>.Index(2))
// => [0, 1]
```

#### .subArray(fromIndex:)

``` Swift
SortedArray(array: [5, 2, 1, 3, 0, 4]).subArray(fromIndex: Array<Int>.Index(2))
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
frequencyTable.sample()
let randomWord = frequencyTable.sample().map{ $0.word }
// => "Harry"
```

#### .sample(size:)

Returns an array with `size` frequency-based random elements or nil if array empty.

``` Swift
frequencyTable.sample(size: 6)
let randomWords = frequencyTable.sample(size: 6)!.map{ $0.word }
// => ["Harry", "Ronald", "Harry", "Harry", "Hermione", "Hermione"]
```


## Contributing

Contributions are welcome. Please just open an Issue on GitHub to discuss a point or request a feature or send a Pull Request with your suggestion. If there's a related discussion on the Swift Evolution mailing list, please also post the thread name with a link.

Pull requests with new features will only be accepted when the following are given:
- The feature is **handy** but not (yet) part of the Swift standard library.
- **Tests** for the new feature exist and all tests pass successfully.
- **Usage examples** of the new feature are given in the Playgrounds.

Please also try to follow the same syntax and semantic in your **commit messages** (see rationale [here](http://chris.beams.io/posts/git-commit/)).


## License
This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
