//: This Playground demonstrates the issue with Unicode (e.g. Smiley) characters only in matching lines.
import Foundation


let commentLineNoUnicodeValue = "/* Completely custom comment structure in one line to be ignored */"
let keyValueLineNoUnicodeValue = "\"test.key.ignored\" = \"This is a test key to be ignored #bc-ignore!\";"

let commentLineUnicodeOnlyValue = "/* Class = \"UIButton\"; normalTitle = \"😀\"; ObjectID = \"abc-12-345\"; */"
let keyValueLineUnicodeOnlyValue = "\"abc-12-345.normalTitle\" = \"😀\";"

let commentLineUnicodeMixedValue = "/* Class = \"UIButton\"; normalTitle = \"Mixed with 😀\"; ObjectID = \"abc-12-345\"; */"
let keyValueLineUnicodeMixedValue = "\"abc-12-345.normalTitle\" = \"Mixed with 😀\";"



let commentLineRegex = try NSRegularExpression(pattern: "^\\s*/\\*(.*)\\*/\\s*$", options: .CaseInsensitive)
let keyValueLineRegex = try NSRegularExpression(pattern: "^\\s*\"(.*)\"\\s*=\\s*\"(.*)\"\\s*;$", options: .CaseInsensitive)



commentLineRegex.matchesInString(commentLineNoUnicodeValue, options: .ReportCompletion, range: NSMakeRange(0, commentLineNoUnicodeValue.characters.count)).first
keyValueLineRegex.matchesInString(keyValueLineNoUnicodeValue, options: .ReportCompletion, range: NSMakeRange(0, keyValueLineNoUnicodeValue.characters.count)).first

commentLineRegex.matchesInString(commentLineUnicodeOnlyValue, options: .ReportCompletion, range: NSMakeRange(0, commentLineUnicodeOnlyValue.characters.count)).first
keyValueLineRegex.matchesInString(keyValueLineUnicodeOnlyValue, options: .ReportCompletion, range: NSMakeRange(0, keyValueLineUnicodeOnlyValue.characters.count)).first

commentLineRegex.matchesInString(commentLineUnicodeMixedValue, options: .ReportCompletion, range: NSMakeRange(0, commentLineUnicodeMixedValue.characters.count)).first
keyValueLineRegex.matchesInString(keyValueLineUnicodeMixedValue, options: .ReportCompletion, range: NSMakeRange(0, keyValueLineUnicodeMixedValue.characters.count)).first