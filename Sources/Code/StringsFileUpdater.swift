//
//  StringsFileUpdater.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 10.02.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

// swiftlint:disable function_body_length
// swiftlint:disable file_length

import Foundation

public class StringsFileUpdater {
    // MARK: - Sub Types

    typealias TranslationEntry = (key: String, value: String, comment: String?, line: Int)


    // MARK: - Stored Type Properties

    static let defaultIgnoreKeys = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]


    // MARK: - Stored Instance Properties

    let path: String
    var oldContentString: String = ""


    // MARK: - Initializers

    public init?(path: String) {
        self.path = path
        do {
            self.oldContentString = try String(contentsOfFile: path)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    // Updates the keys of this instances strings file with those of the given strings file.
    public func incrementallyUpdateKeys(withStringsFileAtPath otherStringFilePath: String,
                                        addNewValuesAsEmpty: Bool, ignoreBaseKeysAndComment ignores: [String] = defaultIgnoreKeys,
                                        override: Bool = false, updateCommentWithBase: Bool = true, keepExistingKeys: Bool = false,
                                        overrideComments: Bool = false, sortByKeys: Bool = false) {
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)

            let oldTranslations = findTranslations(inString: oldContentString)
            var newTranslations = findTranslations(inString: newContentString)

            if let lastOldTranslation = oldTranslations.last {
                newTranslations = newTranslations.map { ($0.0, $0.1, $0.2, $0.3+lastOldTranslation.line+1) }
            }

            let updatedTranslations: [TranslationEntry] = {
                var translations: [TranslationEntry] = []

                if keepExistingKeys {
                    translations += oldTranslations.filter { (oldKey, _, _, _) in
                        return newTranslations.filter { (newKey, _, _, _) in oldKey == newKey }.isEmpty
                    }
                }

                for newTranslation in newTranslations {
                    // skip keys marked for ignore
                    guard !newTranslation.value.containsAny(of: ignores) else { continue }

                    // Skip keys that have been marked for ignore in comment
                    if let newComment = newTranslation.comment, newComment.containsAny(of: ignores) { continue }

                    let oldTranslation = oldTranslations.first { (oldKey, _, _, _) in oldKey == newTranslation.key }

                    // get value from default comment structure if possible
                    let oldBaseValue: String? = {
                        if let oldComment = oldTranslation?.comment, let foundMatch = defaultCommentStructureMatches(inString: oldComment) {
                            return (oldComment as NSString).substring(with: foundMatch.rangeAt(1))
                        }
                        return nil
                    }()

                    let updatedComment: String? = {
                        // add new comment if none existed before
                        guard let oldComment = oldTranslation?.2 else { return newTranslation.comment }

                        // keep old comment if no new comment exists
                        guard let newComment = newTranslation.comment else { return oldComment }

                        // override with comment in force update mode
                        if override || overrideComments { return newComment }

                        // update if implicit requirements fullfilled
                        if updateCommentWithBase && defaultCommentStructureMatches(inString: oldComment) != nil { return newComment }

                        return oldComment
                    }()

                    let updatedValue: String = {
                        guard let oldValue = oldTranslation?.1 else {
                            // add new key with empty value
                            if addNewValuesAsEmpty { return "" }

                            // add new key with Base value
                            return newTranslation.value
                        }

                        if override { return newTranslation.value } // override with new value in force update mode

                        if let oldBaseValue = oldBaseValue, oldBaseValue == oldValue { return newTranslation.value } // update base value

                        // keep existing translation
                        return oldValue
                    }()

                    // don't change order of existing translations if no specific order specified
                    let updatedLine: Int = oldTranslation?.line ?? newTranslation.line

                    translations.append((newTranslation.key, updatedValue, updatedComment, updatedLine))
                }

                let sortingClosure: (TranslationEntry, TranslationEntry) -> Bool = {
                    if sortByKeys {
                        return { (translation1, translation2) in
                            // ensure keys with empty values are appended to the end
                            if translation1.value.isEmpty == translation2.value.isEmpty {
                                return translation1.key.lowercased() < translation2.key.lowercased()
                            } else {
                                return translation2.value.isEmpty
                            }
                        }
                    } else {
                        return { (translation1, translation2) in translation1.line < translation2.line }
                    }
                }()

                return translations.sorted(by: sortingClosure)
            }()

            rewriteFile(with: updatedTranslations)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func defaultCommentStructureMatches(inString string: String) -> NSTextCheckingResult? {
        // swiftlint:disable:next force_try
        let defaultCommentStructureRegex = try! NSRegularExpression(pattern: "\\A Class = \".*\"; .* = \"(.*)\"; ObjectID = \".*\"; \\z", options: .caseInsensitive)
        return defaultCommentStructureRegex.firstMatch(in: string, options: .reportCompletion, range: string.fullRange)
    }

    // Rewrites file with specified translations and reloads lines from new file.
    func rewriteFile(with translations: [TranslationEntry]) {
        do {
            let newContentsOfFile = stringFromTranslations(translations: translations)

            try FileManager.default.removeItem(atPath: path)
            try newContentsOfFile.write(toFile: path, atomically: true, encoding: .utf8)

            self.oldContentString = try String(contentsOfFile: path)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Translates all empty values of this instances strings file using the Microsoft Translator API.
    /// Note that this will only work for languages supported by the Microsoft Translator API and Polyglot.
    /// See here for a full list: https://www.microsoft.com/en-us/translator/faq.aspx
    ///
    /// Note that you need to register for the Microsoft Translator API here:
    /// https://datamarket.azure.com/dataset/bing/microsofttranslator
    ///
    /// Then you can register your client to retrieve the client id & secret here:
    /// https://datamarket.azure.com/developer/applications
    ///
    /// - Parameters:
    ///   - usingValuesFromStringsFile:     The path to the strings file to use as source language for the translation.
    ///   - clientId:                       The Microsoft Translator API Client ID.
    ///   - clientSecret:                   The Microsoft Translator API Client Secret.
    ///   - override:                       Specified if values should be overridden.
    /// - Returns: The number of values translated successfully.
    public func translateEmptyValues(usingValuesFromStringsFile sourceStringsFilePath: String,
                                     clientId: String, clientSecret: String, override: Bool = false) -> Int {
        guard let (sourceLanguage, sourceRegion) = extractLocale(fromPath: sourceStringsFilePath) else {
            print("Error! Could not obtain source locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
            return 0
        }

        guard let (targetLanguage, targetRegion) = extractLocale(fromPath: path) else {
            print("Error! Could not obtain target locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
            return 0
        }

        guard let sourceTranslatorLanguage = Language.languageForLocale(languageCode: sourceLanguage, region: sourceRegion) else {
            let locale = sourceRegion != nil ? "\(sourceLanguage)-\(sourceRegion!)" : sourceLanguage
            print("Warning! Automatic translation from the locale '\(locale)' is not supported.")
            return 0
        }

        guard let targetTranslatorLanguage = Language.languageForLocale(languageCode: targetLanguage, region: targetRegion) else {
            let locale = targetRegion != nil ? "\(targetLanguage)-\(targetRegion!)" : targetLanguage
            print("Warning! Automatic translation to the locale '\(locale)' is not supported.")
            return 0
        }

        do {
            let sourceContentString = try String(contentsOfFile: sourceStringsFilePath)

            let translator = Polyglot(clientId: clientId, clientSecret: clientSecret)

            translator.fromLanguage = sourceTranslatorLanguage
            translator.toLanguage = targetTranslatorLanguage

            var translatedValuesCount = 0
            var awaitingTranslationRequestsCount = 0

            let sourceTranslations = findTranslations(inString: sourceContentString)
            let existingTargetTranslations = findTranslations(inString: oldContentString)
            var updatedTargetTranslations: [TranslationEntry] = []

            for sourceTranslation in sourceTranslations {
                let (sourceKey, sourceValue, sourceComment, sourceLine) = sourceTranslation
                var targetTranslationOptional = existingTargetTranslations.filter { $0.0 == sourceKey }.first

                if targetTranslationOptional == nil {
                    targetTranslationOptional = (sourceKey, "", sourceComment, sourceLine)
                }

                guard let targetTranslation = targetTranslationOptional else {
                    NSException(name: NSExceptionName(rawValue: "targetTranslation was nil when not expected"), reason: nil, userInfo: nil).raise()
                    exit(EXIT_FAILURE)
                }
                let (key, value, comment, line) = targetTranslation

                guard value.isEmpty || override else {
                    updatedTargetTranslations.append(targetTranslation)
                    continue // skip already translated values
                }

                guard !sourceValue.isEmpty else {
                    print("Warning! Value for key '\(key)' in source translations is empty.")
                    continue
                }

                awaitingTranslationRequestsCount += 1
                let updatedTargetTranslationIndex = updatedTargetTranslations.count
                updatedTargetTranslations.append(targetTranslation)

                translator.translate(sourceValue) { translatedValue in
                    if !translatedValue.isEmpty {
                        updatedTargetTranslations[updatedTargetTranslationIndex] = (key, translatedValue.asStringLiteral, comment, line)
                        translatedValuesCount += 1
                    }

                    awaitingTranslationRequestsCount -= 1
                }
            }

            // wait for callbacks of all asynchronous translation calls -- will wait forever if any callback doesn't fire
            while awaitingTranslationRequestsCount > 0 {}

            if translatedValuesCount > 0 { rewriteFile(with: updatedTargetTranslations) }

            return translatedValuesCount
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }

    // - Returns: An array containing all found translations as tuples in the format `(key, value, comment?)`.
    func findTranslations(inString string: String) -> [TranslationEntry] {
        // comment pattern adapted from http://blog.ostermiller.org/find-comment
        let translationRegexString = "(?:\\s*/\\*(((?:[^*]|(?:\\*+(?:[^*/])))*))\\*+/\\s*)?\\s*(?:^\\s*\"([\\S  ]*)\"\\s*=\\s*\"([\\S  ]*)\"\\s*;\\s*$)"

        // swiftlint:disable force_try
        let translationRegex = try! NSRegularExpression(pattern: translationRegexString, options: [.dotMatchesLineSeparators, .anchorsMatchLines])
        let newlineRegex = try! NSRegularExpression(pattern: "(\\n)", options: .useUnixLineSeparators)
        // swiftlint:enable force_try

        let positionsOfNewlines = SortedArray(array: newlineRegex.matches(in: string, options: .reportCompletion, range: string.fullRange).map { $0.rangeAt(1).location })

        let matches = translationRegex.matches(in: string, options: .reportCompletion, range: string.fullRange)
        var translations: [TranslationEntry] = []
        autoreleasepool {
            translations = matches.map { match in
                let valueRange = match.rangeAt(match.numberOfRanges - 1)
                let value: String = (string as NSString).substring(with: valueRange)
                let key = (string as NSString).substring(with: match.rangeAt(match.numberOfRanges - 2))
                var comment: String?
                if match.numberOfRanges >= 4 {
                    let range = match.rangeAt(match.numberOfRanges - 3)
                    if range.location != NSNotFound && range.length > 0 { comment = (string as NSString).substring(with: range) }
                }
                let numberOfNewlines = positionsOfNewlines.firstMatchingIndex { $0 > valueRange.location + valueRange.length } ?? positionsOfNewlines.array.count
                return TranslationEntry(key: key, value: value, comment: comment, line: numberOfNewlines - 1)
            }
        }
        return translations
    }

    func stringFromTranslations(translations: [TranslationEntry]) -> String {
        return "\n" + translations.map { (key, value, comment, line) -> String in
            let translationLine = "\"\(key)\" = \"\(value)\";"
            if let comment = comment { return "/*\(comment)*/\n" + translationLine }
            return translationLine
        }.joined(separator: "\n\n") + "\n"
    }

    /// Extracts locale from a path containing substring `{language}-{region}.lproj` or `{language}.lproj`.
    ///
    /// - Parameters:
    ///   - fromPath: The path to extract the locale from.
    /// - Returns: A tuple containing the extracted language and region (if any) or nil if couldn't find locale in path.
    func extractLocale(fromPath path: String) -> (language: String, region: String?)? {
        // Initialize regular expressions -- swiftlint:disable force_try
        let languageRegex = try! NSRegularExpression(pattern: "(\\w{2})-{0,1}\\w*\\.lproj", options: .caseInsensitive)
        let regionRegex = try! NSRegularExpression(pattern: "\\w{2}-(\\w+)\\.lproj", options: .caseInsensitive)
        // swiftlint:enable force_try

        // Get language from path
        guard let languageMatch = languageRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else { return nil }
        let language = (path as NSString).substring(with: languageMatch.rangeAt(1))

        // Get region from path if existent
        guard let regionMatch = regionRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else {
            return (language, nil)
        }

        let region = (path as NSString).substring(with: regionMatch.rangeAt(1))
        return (language, region)
    }
}


// MARK: - String Extension

extension String {
    func containsAny(of substrings: [String]) -> Bool {
        for substring in substrings {
            if contains(substring) { return true }
        }
        return false
    }

    /// Unescapes any special characters to make String valid String Literal.
    ///
    /// Source: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/StringsAndCharacters.html (to be cont.)
    /// Continued: #//apple_ref/doc/uid/TP40014097-CH7-ID295
    var asStringLiteral: String {
        let charactersToEscape = ["\\", "\""] // important: backslash must be first entry
        var escapedString = self

        charactersToEscape.forEach { character in
            escapedString = escapedString.replacingOccurrences(of: character, with: "\\\(character)")
        }

        return escapedString
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
}

// swiftlint:enable function_body_length
// swiftlint:enable file_length
