//  Created by Cihat Gündüz on 10.02.16.

// swiftlint:disable function_body_length type_body_length file_length

import Foundation
import HandySwift
import MungoHealer
import BartyCrouchTranslator

public class StringsFileUpdater {
    // MARK: - Sub Types
    typealias TranslationEntry = (key: String, value: String, comment: String?, line: Int)
    typealias LocaleInfo = (language: String, region: String?)

    // MARK: - Stored Type Properties
    public static let defaultIgnoreKeys: [String] = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]

    // MARK: - Stored Instance Properties
    let path: String
    var oldContentString: String = ""

    // MARK: - Initializers
    public init?(path: String) {
        self.path = path
        do {
            self.oldContentString = try String(contentsOfFile: path)
        } catch {
            print(error.localizedDescription, level: .error)
            return nil
        }
    }

    // MARK: - Methods
    // Updates the keys of this instances strings file with those of the given strings file.
    public func incrementallyUpdateKeys(
        withStringsFileAtPath otherStringFilePath: String,
        addNewValuesAsEmpty: Bool,
        ignoreBaseKeysAndComment ignores: [String] = defaultIgnoreKeys,
        override: Bool = false,
        updateCommentWithBase: Bool = true,
        keepExistingKeys: Bool = false,
        overrideComments: Bool = false,
        keepWhitespaceSurroundings: Bool = false,
        ignoreEmptyStrings: Bool = false
    ) {
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)

            let oldTranslations = findTranslations(inString: oldContentString)
            var newTranslations = findTranslations(inString: newContentString)

            if let lastOldTranslation = oldTranslations.last {
                newTranslations = newTranslations.map { ($0.key, $0.value, $0.comment, $0.line + lastOldTranslation.line + 1) }
            }

            let updatedTranslations: [TranslationEntry] = {
                var translations: [TranslationEntry] = []

                if keepExistingKeys {
                    translations += oldTranslations.filter { oldKey, _, _, _ in
                        return newTranslations.filter { newKey, _, _, _ in oldKey == newKey }.isEmpty
                    }
                }

                for newTranslation in newTranslations {
                    // skip keys marked for ignore
                    guard !newTranslation.value.containsAny(of: ignores) else { continue }
                    if ignoreEmptyStrings && newTranslation.value.isBlank { continue }

                    // Skip keys that have been marked for ignore in comment
                    if let newComment = newTranslation.comment, newComment.containsAny(of: ignores) { continue }

                    let oldTranslation = oldTranslations.first { oldKey, _, _, _ in oldKey == newTranslation.key }

                    // get value from default comment structure if possible
                    let oldBaseValue: String? = {
                        guard let oldComment = oldTranslation?.comment, let foundMatch = defaultCommentStructureMatches(inString: oldComment) else {
                            return nil
                        }

                        return (oldComment as NSString).substring(with: foundMatch.range(at: 1))
                    }()

                    let updatedComment: String? = {
                        // add new comment if none existed before
                        guard let oldComment = oldTranslation?.comment else { return newTranslation.comment }

                        // keep old comment if no new comment exists
                        guard let newComment = newTranslation.comment else { return oldComment }

                        // override with comment in force update mode
                        if override || overrideComments { return newComment }

                        // update if implicit requirements fullfilled
                        if updateCommentWithBase && defaultCommentStructureMatches(inString: oldComment) != nil { return newComment }

                        return oldComment
                    }()

                    let updatedValue: String = {
                        // get new translation value corrected by false % placeholders
                        var newTranslationValue = newTranslation.value
                        // swiftlint:disable:next force_try
                        let regex = try! Regex("%\\d\\$((?![@dcixoufegap]|[l]{1,2}[duixo]|[h][duixo]|L[dfega]|\\.\\d))", options: [])
                        newTranslationValue = regex.replacingMatches(in: newTranslationValue, with: "%$1")

                        guard let oldValue = oldTranslation?.value else {
                            // add new key with empty value
                            guard !addNewValuesAsEmpty else { return "" }

                            // add new key with Base value
                            return newTranslationValue
                        }

                        if override { return newTranslationValue } // override with new value in force update mode

                        if let oldBaseValue = oldBaseValue, oldBaseValue == oldValue { return newTranslationValue } // update base value

                        // keep existing translation
                        return oldValue
                    }()

                    // don't change order of existing translations if no specific order specified
                    let updatedLine: Int = oldTranslation?.line ?? newTranslation.line

                    translations.append((newTranslation.key, updatedValue, updatedComment, updatedLine))
                }

                let sortingClosure: (TranslationEntry, TranslationEntry) -> Bool = {
                    return { translation1, translation2 in translation1.line < translation2.line }
                }()

                return translations.sorted(by: sortingClosure)
            }()

            rewriteFile(with: updatedTranslations, keepWhitespaceSurroundings: keepWhitespaceSurroundings)
        } catch {
            print(error.localizedDescription, level: .error)
        }
    }

    public func sortByKeys(keepWhitespaceSurroundings: Bool = false) {
        let translations = findTranslations(inString: oldContentString)
        let sortedTranslations = translations.sorted(by: translationEntrySortingClosure(lhs:rhs:), stable: true)

        rewriteFile(with: sortedTranslations, keepWhitespaceSurroundings: keepWhitespaceSurroundings)
    }

    private func translationEntrySortingClosure(lhs: TranslationEntry, rhs: TranslationEntry) -> Bool {
        // ensure keys with empty values are appended to the end
        if lhs.value.isEmpty == rhs.value.isEmpty {
            return lhs.key.lowercased() < rhs.key.lowercased()
        } else {
            return rhs.value.isEmpty
        }
    }

    private func defaultCommentStructureMatches(inString string: String) -> NSTextCheckingResult? {
        // swiftlint:disable:next force_try
        let defaultCommentStructureRegex = try! NSRegularExpression(
            pattern: "\\A Class = \".*\"; .* = \"(.*)\"; ObjectID = \".*\"; \\z", options: .caseInsensitive
        )
        return defaultCommentStructureRegex.firstMatch(in: string, options: .reportCompletion, range: string.fullRange)
    }

    // Rewrites file with specified translations and reloads lines from new file.
    func rewriteFile(with translations: [TranslationEntry], keepWhitespaceSurroundings: Bool) {
        do {
            var newContentsOfFile = stringFromTranslations(translations: translations)

            if keepWhitespaceSurroundings {
                var whitespacesOrNewlinesAtEnd = ""
                for index in 1 ... 10 { // allows a maximum of 10 whitespace chars at end
                    let substring = String(oldContentString.suffix(index))
                    if substring.isBlank {
                        whitespacesOrNewlinesAtEnd = substring
                    } else {
                        break
                    }
                }

                var whitespacesOrNewlinesAtBegin = ""
                for index in 1 ... 10 { // allows a maximum of 10 whitespace chars at end
                    if oldContentString.count < index {
                        break
                    }

                    let substring = String(oldContentString.suffix(oldContentString.count - index))
                    if substring.isBlank {
                        whitespacesOrNewlinesAtBegin = substring
                    } else {
                        break
                    }
                }

                newContentsOfFile = whitespacesOrNewlinesAtBegin + newContentsOfFile.stripped() + whitespacesOrNewlinesAtEnd
            }

            try FileManager.default.removeItem(atPath: path)
            try newContentsOfFile.write(toFile: path, atomically: true, encoding: .utf8)

            self.oldContentString = try String(contentsOfFile: path)
        } catch {
            print(error.localizedDescription, level: .error)
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
    public func translateEmptyValues(
        usingValuesFromStringsFile sourceStringsFilePath: String,
        clientId: String,
        clientSecret: String,
        override: Bool = false
    ) throws -> Int {
        guard let (sourceLanguage, sourceRegion) = extractLocale(fromPath: sourceStringsFilePath) else {
            throw MungoFatalError(source: .invalidUserInput, message: "Could not obtain source locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
        }

        guard let (targetLanguage, targetRegion) = extractLocale(fromPath: path) else {
            throw MungoFatalError(source: .invalidUserInput, message: "Could not obtain target locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
        }

        guard let sourceTranslatorLanguage = Language.with(languageCode: sourceLanguage, region: sourceRegion) else {
            let locale = sourceRegion != nil ? "\(sourceLanguage)-\(sourceRegion!)" : sourceLanguage
            throw MungoFatalError(source: .invalidUserInput, message: "Automatic translation from the locale '\(locale)' is not supported.")
        }

        guard let targetTranslatorLanguage = Language.with(languageCode: targetLanguage, region: targetRegion) else {
            let locale = targetRegion != nil ? "\(targetLanguage)-\(targetRegion!)" : targetLanguage
            throw MungoFatalError(source: .invalidUserInput, message: "Automatic translation to the locale '\(locale)' is not supported.")
        }

        do {
            let sourceContentString = try String(contentsOfFile: sourceStringsFilePath)
            var translatedValuesCount = 0

            let sourceTranslations = findTranslations(inString: sourceContentString)
            let existingTargetTranslations = findTranslations(inString: oldContentString)
            var updatedTargetTranslations: [TranslationEntry] = []

            let translator = BartyCrouchTranslator(translationService: .microsoft(subscriptionKey: Secrets.microsoftSubscriptionKey))

            for sourceTranslation in sourceTranslations {
                let (sourceKey, sourceValue, sourceComment, sourceLine) = sourceTranslation
                var targetTranslationOptional = existingTargetTranslations.first { $0.key == sourceKey }

                if targetTranslationOptional == nil {
                    targetTranslationOptional = (sourceKey, "", sourceComment, sourceLine)
                }

                guard let targetTranslation = targetTranslationOptional else {
                    print("targetTranslation was nil when not expected", level: .error)
                    exit(EX_IOERR)
                }

                let (key, value, comment, line) = targetTranslation

                guard value.isEmpty || override else {
                    updatedTargetTranslations.append(targetTranslation)
                    continue // skip already translated values
                }

                guard !sourceValue.isEmpty else {
                    print("Value for key '\(key)' in source translations is empty.", level: .warning)
                    continue
                }

                let updatedTargetTranslationIndex = updatedTargetTranslations.count
                updatedTargetTranslations.append(targetTranslation)

                switch translator.translate(text: sourceValue, from: sourceTranslatorLanguage, to: [targetTranslatorLanguage]) {
                case let .success(translations):
                    if let translatedValue = translations.first?.translatedText {
                        if !translatedValue.isEmpty {
                            updatedTargetTranslations[updatedTargetTranslationIndex] = (key, translatedValue.asStringLiteral, comment, line)
                            translatedValuesCount += 1
                        } else {
                            print("Resulting translation of '\(sourceValue)' to '\(targetTranslatorLanguage)' was empty.", level: .warning)
                        }
                    } else {
                        print("Could not fetch translation for '\(sourceValue)'.", level: .warning)
                    }

                case let .failure(failure):
                    print("Translation request failed with error: \(failure.errorDescription)", level: .warning)
                }
            }

            if translatedValuesCount > 0 { rewriteFile(with: updatedTargetTranslations, keepWhitespaceSurroundings: false) }

            return translatedValuesCount
        } catch {
            print(error.localizedDescription, level: .warning)
            exit(EX_OK)
        }
    }

    // - Returns: An array containing all found translations as tuples in the format `(key, value, comment?)`.
    func findTranslations(inString string: String) -> [TranslationEntry] {
        // comment pattern adapted from http://blog.ostermiller.org/find-comment
        let translationRegexString = "(?:\\s*/\\*(((?:[^*]|(?:\\*+(?:[^*/])))*))\\*+/\\s*)?\\s*(?:^\\s*\"([\\S  ]*)\"\\s*=\\s*\"(.*?)\"\\s*;\\s*$)"

        // swiftlint:disable force_try
        let translationRegex = try! NSRegularExpression(pattern: translationRegexString, options: [.dotMatchesLineSeparators, .anchorsMatchLines])
        let newlineRegex = try! NSRegularExpression(pattern: "(\\n)", options: .useUnixLineSeparators)
        // swiftlint:enable force_try

        let positionsOfNewlines = SortedArray(
            newlineRegex.matches(in: string, options: .reportCompletion, range: string.fullRange).map { $0.range(at: 1).location }
        )

        let matches = translationRegex.matches(in: string, options: .reportCompletion, range: string.fullRange)
        var translations: [TranslationEntry] = []
        autoreleasepool {
            translations = matches.map { match in
                let valueRange = match.range(at: match.numberOfRanges - 1)
                let value: String = (string as NSString).substring(with: valueRange)
                let key = (string as NSString).substring(with: match.range(at: match.numberOfRanges - 2))
                var comment: String?
                if match.numberOfRanges >= 4 {
                    let range = match.range(at: match.numberOfRanges - 3)
                    if range.location != NSNotFound && range.length > 0 { comment = (string as NSString).substring(with: range) }
                }

                let numberOfNewlines = positionsOfNewlines.index { $0 > valueRange.location + valueRange.length } ?? positionsOfNewlines.array.count
                return TranslationEntry(key: key, value: value, comment: comment, line: numberOfNewlines - 1)
            }
        }

        return translations
    }

    func stringFromTranslations(translations: [TranslationEntry]) -> String {
        return "\n" + translations.map { key, value, comment, _ -> String in
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
    func extractLocale(fromPath path: String) -> LocaleInfo? {
        // Initialize regular expressions -- swiftlint:disable force_try
        let languageRegex = try! NSRegularExpression(pattern: "(\\w{2})-{0,1}\\w*\\.lproj", options: .caseInsensitive)
        let regionRegex = try! NSRegularExpression(pattern: "\\w{2}-(\\w+)\\.lproj", options: .caseInsensitive)
        // swiftlint:enable force_try

        // Get language from path
        guard let languageMatch = languageRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else { return nil }
        let language = (path as NSString).substring(with: languageMatch.range(at: 1))

        // Get region from path if existent
        guard let regionMatch = regionRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else {
            return (language, nil)
        }

        let region = (path as NSString).substring(with: regionMatch.range(at: 1))
        return (language, region)
    }

    func findDuplicateEntries() -> [String: [TranslationEntry]] {
        let translations = findTranslations(inString: oldContentString)
        let translationsDict = Dictionary(grouping: translations) { $0.key }
        return translationsDict.filter { $1.count > 1 }
    }

    func preventDuplicateEntries() {
        let translations = findTranslations(inString: oldContentString)
        let translationsDict = Dictionary(grouping: translations) { $0.key }
        let duplicateTranslationsDict = translationsDict.filter { $1.count > 1 }

        var fixedTranslations = Array(translations)

        for (duplicateKey, duplicateKeyTranslations) in duplicateTranslationsDict {
            let firstTranslation = duplicateKeyTranslations.first!

            let hasDifferentValuesOrComments = duplicateKeyTranslations.reduce(false) { result, translation in
                return result || translation.value != firstTranslation.value || translation.comment != firstTranslation.comment
            }

            if hasDifferentValuesOrComments {
                print("Found \(duplicateKeyTranslations.count) entries for key '\(duplicateKey)' with differnt values or comments.", level: .warning)

                duplicateKeyTranslations.forEach { translation in
                    let keyValueLine = translation.line + (translation.comment == nil ? 1 : 2)
                    print(xcodeWarning(filePath: path, line: keyValueLine, message: "Duplicate key. Remove all but one."))
                }
            } else {
                print("Found \(duplicateKeyTranslations.count) entries for key '\(duplicateKey)' with equal values and comments. Keeping one.", level: .info)

                duplicateKeyTranslations.dropFirst().forEach { translation in
                    fixedTranslations = fixedTranslations.filter { $0.line != translation.line }
                }
            }
        }

        rewriteFile(with: fixedTranslations, keepWhitespaceSurroundings: true)
    }

    func findEmptyValueEntries() -> [TranslationEntry] {
        let translations = findTranslations(inString: oldContentString)
        return translations.filter { $0.value.isEmpty }
    }

    func warnEmptyValueEntries() {
        let emptyValueEntries = findEmptyValueEntries()
        emptyValueEntries.forEach { translation in
            let keyValueLine = translation.line + (translation.comment == nil ? 1 : 2)
            print(xcodeWarning(filePath: path, line: keyValueLine, message: "Empty translation value."))
        }
    }

    func harmonizeKeys(withSource sourceFilePath: String) throws {
        let sourceFileContentString = try String(contentsOfFile: sourceFilePath)

        let sourceTranslations = findTranslations(inString: sourceFileContentString)
        let translations = findTranslations(inString: oldContentString)

        var fixedTranslations = Array(translations)

        let sourceTranslationsDict = Dictionary(grouping: sourceTranslations) { $0.key }
        let translationsDict = Dictionary(grouping: translations) { $0.key }

        let keysToAdd = Set(sourceTranslationsDict.keys).subtracting(translationsDict.keys)
        let keysToRemove = Set(translationsDict.keys).subtracting(sourceTranslationsDict.keys)

        let translationsToAdd = sourceTranslationsDict.filter { keysToAdd.contains($0.key) }.mapValues { $0.first! }
        if !translationsToAdd.isEmpty {
            print("Adding missing keys \(translationsToAdd.keys) to Strings file \(path).", level: .info)
        }

        translationsToAdd.sorted { lhs, rhs in lhs.value.line < rhs.value.line }.forEach { translationTuple in
            fixedTranslations.append(translationTuple.value)
        }

        if !keysToRemove.isEmpty {
            print("Removing unnecessary keys \(keysToRemove) from Strings file \(path).", level: .info)
        }

        keysToRemove.forEach { keyToRemove in
            fixedTranslations = fixedTranslations.filter { $0.key != keyToRemove }
        }

        rewriteFile(with: fixedTranslations, keepWhitespaceSurroundings: true)
    }

    func xcodeWarning(filePath: String, line: Int, message: String) -> String {
        return "\(filePath):\(line): warning: BartyCrouch: \(message)"
    }
}

// MARK: - String Extension
extension String {
    /// Unescapes any special characters to make String valid String Literal.
    var asStringLiteral: String {
        let charactersToEscape = ["\\", "\""] // important: backslash must be first entry
        var escapedString = self

        charactersToEscape.forEach { character in
            escapedString = escapedString.replacingOccurrences(of: character, with: "\\\(character)")
        }

        return escapedString
    }

    func containsAny(of substrings: [String]) -> Bool {
        for substring in substrings { // swiftlint:disable:this if_as_guard
            if contains(substring) { return true }
        }

        return false
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
}
