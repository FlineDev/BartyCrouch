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

    typealias TranslationEntry = (key: String, value: String, comment: String?, line: Int)

    let path: String
    var linesInFile: [String]

    static let defaultIgnoreKeys = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]


    // MARK: - Initializers

    public init?(path: String) {
        self.path = path
        do {
            let contentString = try String(contentsOfFile: path)
            self.linesInFile = contentString.components(separatedBy: .newlines)
        } catch {
            print((error as NSError).description)
            self.linesInFile = []
            return nil
        }
    }

    // Updates the keys of this instances strings file with those of the given strings file.
    // Note that this will add new keys, remove not-existing keys but won't touch any existing ones.
    public func incrementallyUpdateKeys(withStringsFileAtPath otherStringFilePath: String, // swiftlint:disable:this cyclomatic_complexity
                                        addNewValuesAsEmpty: Bool, ignoreBaseKeysAndComment ignores: [String] = defaultIgnoreKeys,
                                        override: Bool = false, updateCommentWithBase: Bool = true, keepExistingKeys: Bool = false) {
        do {
            let newContentString = try String(contentsOfFile: otherStringFilePath)
            let linesInNewFile = newContentString.components(separatedBy: .newlines)

            let oldTranslations = self.findTranslations(inLines: self.linesInFile)
            var newTranslations = self.findTranslations(inLines: linesInNewFile)

            if let lastOldTranslation = oldTranslations.last {
                newTranslations = newTranslations.map { ($0.0, $0.1, $0.2, $0.3+lastOldTranslation.line+1) }
            }

            let updatedTranslations: [TranslationEntry] = {
                var translations: [TranslationEntry] = []

                if keepExistingKeys {
                    for (key, oldValue, oldComment, oldLine) in oldTranslations {
                        let oldTranslationEntry = (key, oldValue, oldComment, oldLine)
                        translations.append(oldTranslationEntry)
                    }
                }

                for (key, newValue, newComment, newLine) in newTranslations {

                    // skip keys marked for ignore
                    guard !newValue.containsAny(ofStrings: ignores) else {
                        continue
                    }

                    // Skip keys that have been marked for ignore in comment
                    if let newComment = newComment, newComment.containsAny(ofStrings: ignores) {
                        continue
                    }

                    let oldTranslation = oldTranslations.filter { $0.0 == key }.first

                    // get value from default comment structure if possible
                    let oldBaseValue: String? = {
                        if let oldComment = oldTranslation?.2 {
                            if let foundMatch = self.defaultCommentStructureMatches(inString: oldComment) {
                                return (oldComment as NSString).substring(with: foundMatch.rangeAt(1))
                            }
                        }
                        return nil
                    }()

                    let updatedComment: String? = {
                        guard let oldComment = oldTranslation?.2 else {
                            // add new comment if none existed before
                            return newComment
                        }

                        guard let newComment = newComment else {
                            // keep old comment if no new comment exists
                            return oldComment
                        }

                        if override {
                            // override with comment in force update mode
                            return newComment
                        }

                        if updateCommentWithBase && self.defaultCommentStructureMatches(inString: oldComment) != nil {
                            // update
                            return newComment
                        } else {
                            return oldComment
                        }
                    }()

                    let updatedValue: String = {
                        guard let oldValue = oldTranslation?.1 else {
                            if addNewValuesAsEmpty {
                                // add new key with empty value
                                return ""
                            } else {
                                // add new key with Base value
                                return newValue
                            }
                        }

                        if override {
                            // override with new value in force update mode
                            return newValue
                        }

                        if let oldBaseValue = oldBaseValue {
                            if oldBaseValue == oldValue {
                                // update base value
                                return newValue
                            }
                        }

                        // keep existing translation
                        return oldValue
                    }()

                    let updatedLine: Int = {
                        guard let oldLine = oldTranslation?.line else {
                            return newLine
                        }

                        // don't change order of existing translations
                        return oldLine
                    }()

                    let updatedTranslation = (key, updatedValue, updatedComment, updatedLine)
                    translations.append(updatedTranslation)
                }

                let sortedTranslations = translations.sorted(by: { (translation1: TranslationEntry, translation2: TranslationEntry) -> Bool in
                    return translation1.line < translation2.line
                })

                return sortedTranslations
            }()

            self.rewriteFileWithTranslations(translations: updatedTranslations)
        } catch {
            print((error as NSError).description)
        }
    }

    private func defaultCommentStructureMatches(inString string: String) -> NSTextCheckingResult? {
        do {
            let defaultCommentStructureRegex = try NSRegularExpression(pattern: "\\A Class = \".*\"; .* = \"(.*)\"; ObjectID = \".*\"; \\z", options: .caseInsensitive)
            return defaultCommentStructureRegex.matches(in: string, options: .reportCompletion, range: string.fullRange).first
        } catch {
            return nil
        }
    }

    // Rewrites file with specified translations and reloads lines from new file.
    func rewriteFileWithTranslations(translations: [TranslationEntry]) {

        do {
            let newContentsOfFile = self.stringFromTranslations(translations: translations)

            try FileManager.default.removeItem(atPath: self.path)
            try newContentsOfFile.write(toFile: self.path, atomically: true, encoding: String.Encoding.utf8)

            let contentString = try String(contentsOfFile: self.path)
            self.linesInFile = contentString.components(separatedBy: .newlines)

        } catch {
            print((error as NSError).description)
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
    public func translateEmptyValues(usingValuesFromStringsFile sourceStringsFilePath: String, // swiftlint:disable:this cyclomatic_complexity
                                     clientId: String, clientSecret: String, override: Bool = false) -> Int {

        guard let (sourceLanguage, sourceRegion) = self.extractLocale(fromPath: sourceStringsFilePath) else {
            print("Error! Could not obtain source locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing.")
            return 0
        }

        guard let (targetLanguage, targetRegion) = self.extractLocale(fromPath: self.path) else {
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
            let linesInSourceFile = sourceContentString.components(separatedBy: .newlines)

            let translator = Polyglot(clientId: clientId, clientSecret: clientSecret)

            translator.fromLanguage = sourceTranslatorLanguage
            translator.toLanguage = targetTranslatorLanguage

            var translatedValuesCount = 0
            var awaitingTranslationRequestCount = 0

            let sourceTranslations = self.findTranslations(inLines: linesInSourceFile)
            let existingTargetTranslations = self.findTranslations(inLines: self.linesInFile)
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

                awaitingTranslationRequestCount += 1
                let updatedTargetTranslationIndex = updatedTargetTranslations.count
                updatedTargetTranslations.append(targetTranslation)

                translator.translate(sourceValue, callback: { translatedValue in
                    if !translatedValue.isEmpty {
                        updatedTargetTranslations[updatedTargetTranslationIndex] = (key, translatedValue.asStringLiteral, comment, line)
                        translatedValuesCount += 1
                    }

                    awaitingTranslationRequestCount -= 1
                })
            }

            // wait for callbacks of all asynchronous translation calls -- will wait forever if any callback doesn't fire
            while awaitingTranslationRequestCount > 0 {
                // noop
            }

            if translatedValuesCount > 0 {
                self.rewriteFileWithTranslations(translations: updatedTargetTranslations)
            }

            return translatedValuesCount
        } catch {
            print((error as NSError).description)
            return 0
        }

    }

    // - Returns: An array containing all found translations as tuples in the format `(key, value, comment?)`.
    func findTranslations(inLines lines: [String]) -> [TranslationEntry] {

        var foundTranslations: [TranslationEntry] = []
        var lastCommentLine: String?

        do {
            let commentLineRegex = try NSRegularExpression(pattern: "^\\s*/\\*(.*)\\*/\\s*$", options: .caseInsensitive)
            let keyValueLineRegex = try NSRegularExpression(pattern: "^\\s*\"(.*)\"\\s*=\\s*\"(.*)\"\\s*;$", options: .caseInsensitive)

            lines.enumerated().forEach { lineNum, line in
                if let commentLineMatch = commentLineRegex.firstMatch(in: line, options: .reportCompletion, range: line.fullRange) {
                    lastCommentLine = (line as NSString).substring(with: commentLineMatch.rangeAt(1))
                }

                if let keyValueLineMatch = keyValueLineRegex.firstMatch(in: line, options: .reportCompletion, range: line.fullRange) {

                    let key = (line as NSString).substring(with: keyValueLineMatch.rangeAt(1))
                    let value = (line as NSString).substring(with: keyValueLineMatch.rangeAt(2))

                    let foundTranslation = (key, value, lastCommentLine, lineNum)
                    foundTranslations.append(foundTranslation)

                    lastCommentLine = nil
                }
            }

        } catch {

            print("Finding translations in lines failed")

        }

        return foundTranslations

    }

    func stringFromTranslations(translations: [TranslationEntry]) -> String {

        var resultingString = "\n"

        let translationStrings = translations.map { (key, value, comment, line) -> String in
            let translationString: String = comment != nil ? "/*\(comment!)*/\n" : ""
            return translationString + "\"\(key)\" = \"\(value)\";"
        }

        resultingString += translationStrings.joined(separator: "\n\n")

        return resultingString + "\n"
    }


    /// Extracts locale from a path containing substring `{language}-{region}.lproj` or `{language}.lproj`.
    ///
    /// - Parameters:
    ///   - fromPath: The path to extract the locale from.
    /// - Returns: A tuple containing the extracted language and region (if any) or nil if couldn't find locale in path.
    func extractLocale(fromPath path: String) -> (language: String, region: String?)? {

        do {
            // Initialize regular expressions
            let languageRegex = try NSRegularExpression(pattern: "(\\w{2})-{0,1}\\w*\\.lproj", options: .caseInsensitive)
            let regionRegex = try NSRegularExpression(pattern: "\\w{2}-(\\w+)\\.lproj", options: .caseInsensitive)

            // Get language from path
            guard let languageMatch = languageRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else {
                return nil
            }
            let language = (path as NSString).substring(with: languageMatch.rangeAt(1))


            // Get region from path if existent
            var region: String? = nil

            if let regionMatch = regionRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last {
                region = (path as NSString).substring(with: regionMatch.rangeAt(1))
            }

            return (language, region)

        } catch {
            print("Error! Could not instantiate regular expressions. Please report this issue on https://github.com/Flinesoft/BartyCrouch/issues.")
            return nil
        }

    }


}


// MARK: - String Extension

extension String {

    func containsAny(ofStrings substrings: [String]) -> Bool {
        for substring in substrings {
            if self.contains(substring) {
                return true
            }
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
        return NSRange(location: 0, length: self.utf16.count)
    }

}

// swiftlint:enable function_body_length
// swiftlint:enable file_length
