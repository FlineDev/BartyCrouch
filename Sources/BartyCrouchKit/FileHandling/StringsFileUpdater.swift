// swiftlint:disable function_body_length type_body_length file_length

import BartyCrouchTranslator
import BartyCrouchUtility
import Foundation
import HandySwift
import MungoHealer

// swiftlint:disable cyclomatic_complexity

// NOTE:
// This file was not refactored as port of the work/big-refactoring branch for version 4.0 to prevent unexpected behavior changes.
// A rewrite after writing extensive tests for the expected behavior could improve readebility, extensibility and performance.

public class StringsFileUpdater {
  // MARK: - Sub Types
  typealias TranslationEntry = (key: String, value: String, comment: String?, line: Int)
  typealias LocaleInfo = (language: String, region: String?)
  typealias DuplicateEntry = (String, [TranslationEntry])

  // MARK: - Stored Instance Properties
  let path: String
  var oldContentString: String = ""

  // MARK: - Initializers
  public init?(
    path: String
  ) {
    self.path = path
    do {
      self.oldContentString = try String(contentsOfFile: path)
    }
    catch {
      return nil
    }
  }

  // MARK: - Methods
  // Updates the keys of this instances strings file with those of the given strings file.
  public func incrementallyUpdateKeys(
    withStringsFileAtPath otherStringFilePath: String,
    addNewValuesAsEmpty: Bool,
    ignoreBaseKeysAndComment ignores: [String],
    override: Bool = false,
    updateCommentWithBase: Bool = true,
    keepExistingKeys: Bool = false,
    overrideComments: Bool = false,
    keepWhitespaceSurroundings: Bool = false,
    ignoreEmptyStrings: Bool = false,
    separateWithEmptyLine: Bool = true
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

          let updatedComment: String? = {
            // add new comment if none existed before
            guard let oldComment = oldTranslation?.comment else { return newTranslation.comment }

            // keep old comment if no new comment exists
            guard let newComment = newTranslation.comment else { return oldComment }

            // override with comment in force update mode
            if override || overrideComments { return newComment }

            // update if implicit requirements fullfilled
            if updateCommentWithBase && defaultCommentStructureMatches(inString: oldComment) != nil {
              return newComment
            }

            return oldComment
          }()

          let updatedValue: String = {
            // get new translation value corrected by false % placeholders
            var newTranslationValue = newTranslation.value
            // swiftlint:disable:next force_try
            let regex = try! Regex(
              "%\\d\\$((?![@dcixoufegap]|[l]{1,2}[duixo]|[h][duixo]|L[dfega]|\\.\\d))",
              options: []
            )
            newTranslationValue = regex.replacingMatches(in: newTranslationValue, with: "%$1")

            guard let oldValue = oldTranslation?.value else {
              // add new key with empty value
              guard !addNewValuesAsEmpty else { return "" }

              // add new key with Base value
              return newTranslationValue
            }

            if override { return newTranslationValue }  // override with new value in force update mode

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

      rewriteFile(
        with: updatedTranslations,
        keepWhitespaceSurroundings: keepWhitespaceSurroundings,
        separateWithEmptyLine: separateWithEmptyLine
      )
    }
    catch {
      print(error.localizedDescription, level: .error, file: path)
    }
  }

  func insert(translateEntries: [CodeFileHandler.TranslateEntry], separateWithEmptyLine: Bool) {
    guard let langCode = extractLangCode(fromPath: path) else {
      print("Could not extract langCode from file.", level: .warning, file: path)
      return
    }

    let oldTranslations: [TranslationEntry] = findTranslations(inString: oldContentString)
    let getTranslation: (CodeFileHandler.TranslateEntry) -> String = {
      $0.translations.first { $0.langCode == langCode }?.translation ?? ""
    }
    let newTranslations: [TranslationEntry] = translateEntries.map { ($0.key, getTranslation($0), $0.comment, 0) }

    rewriteFile(
      with: oldTranslations + newTranslations,
      keepWhitespaceSurroundings: true,
      separateWithEmptyLine: separateWithEmptyLine
    )
  }

  public func sortByKeys(separateWithEmptyLine: Bool, keepWhitespaceSurroundings: Bool = false) {
    let translations = findTranslations(inString: oldContentString)
    let sortedTranslations = translations.sorted(by: translationEntrySortingClosure(lhs:rhs:), stable: true)

    rewriteFile(
      with: sortedTranslations,
      keepWhitespaceSurroundings: false,
      separateWithEmptyLine: separateWithEmptyLine
    )
  }

  private func translationEntrySortingClosure(lhs: TranslationEntry, rhs: TranslationEntry) -> Bool {
    // ensure keys with empty values are appended to the end
    if lhs.value.isEmpty == rhs.value.isEmpty {
      return lhs.key.normalized < rhs.key.normalized
    }
    else {
      return rhs.value.isEmpty
    }
  }

  private func defaultCommentStructureMatches(inString string: String) -> NSTextCheckingResult? {
    // swiftlint:disable:next force_try
    let defaultCommentStructureRegex = try! NSRegularExpression(
      pattern: "\\A Class = \".*\"; .* = \"(.*)\"; ObjectID = \".*\"; \\z",
      options: .caseInsensitive
    )
    return defaultCommentStructureRegex.firstMatch(in: string, options: .reportCompletion, range: string.fullRange)
  }

  // Rewrites file with specified translations and reloads lines from new file.
  func rewriteFile(with translations: [TranslationEntry], keepWhitespaceSurroundings: Bool, separateWithEmptyLine: Bool)
  {
    do {
      var newContentsOfFile = stringFromTranslations(
        translations: translations,
        separateWithEmptyLine: separateWithEmptyLine
      )

      if keepWhitespaceSurroundings {
        var whitespacesOrNewlinesAtEnd = ""
        for index in 1...10 {  // allows a maximum of 10 whitespace chars at end
          let substring = String(oldContentString.suffix(index))
          if substring.isBlank {
            whitespacesOrNewlinesAtEnd = substring
          }
          else {
            break
          }
        }

        var whitespacesOrNewlinesAtBegin = ""
        for index in 1...10 {  // allows a maximum of 10 whitespace chars at end
          if oldContentString.count < index {
            break
          }

          let substring = String(oldContentString.suffix(oldContentString.count - index))
          if substring.isBlank {
            whitespacesOrNewlinesAtBegin = substring
          }
          else {
            break
          }
        }

        newContentsOfFile = whitespacesOrNewlinesAtBegin + newContentsOfFile.stripped() + whitespacesOrNewlinesAtEnd
      }

      if newContentsOfFile != self.oldContentString {
        try newContentsOfFile.write(toFile: path, atomically: true, encoding: .utf8)
        self.oldContentString = newContentsOfFile
      }
    }
    catch {
      print(error.localizedDescription, level: .error, file: path)
    }
  }

  /// Translates all empty values of this instances strings file using the Microsoft Translator API.
  /// Note that this will only work for languages supported by the Microsoft Translator API – see `Language` enum for details.
  ///
  /// Note that you need to register for the Microsoft Translator API here:
  /// https://docs.microsoft.com/en-us/azure/cognitive-services/translator/translator-text-how-to-signup
  ///
  /// - Parameters:
  ///   - usingValuesFromStringsFile:     The path to the strings file to use as source language for the translation.
  ///   - clientSecret:                   The Microsoft Translator API Client Secret.
  ///   - override:                       Specified if values should be overridden.
  /// - Returns: The number of values translated successfully.
  public func translateEmptyValues(
    usingValuesFromStringsFile sourceStringsFilePath: String,
    clientSecret: Secret,
    separateWithEmptyLine: Bool,
    override: Bool = false
  ) throws -> Int {
    guard let (sourceLanguage, sourceRegion) = extractLocale(fromPath: sourceStringsFilePath) else {
      throw MungoFatalError(
        source: .invalidUserInput,
        message:
          "Could not obtain source locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing."
      )
    }

    guard let (targetLanguage, targetRegion) = extractLocale(fromPath: path) else {
      throw MungoFatalError(
        source: .invalidUserInput,
        message:
          "Could not obtain target locale from path '\(sourceStringsFilePath)' – format '{locale}.lproj' missing."
      )
    }

    guard let sourceTranslatorLanguage = Language.with(languageCode: sourceLanguage, region: sourceRegion) else {
      let locale = sourceRegion != nil ? "\(sourceLanguage)-\(sourceRegion!)" : sourceLanguage
      throw MungoFatalError(
        source: .invalidUserInput,
        message: "Automatic translation from the locale '\(locale)' is not supported."
      )
    }

    guard let targetTranslatorLanguage = Language.with(languageCode: targetLanguage, region: targetRegion) else {
      let locale = targetRegion != nil ? "\(targetLanguage)-\(targetRegion!)" : targetLanguage
      print(
        "Automatic translation to the locale '\(locale)' is not supported by Microsoft Translator.",
        level: .warning
      )
      return 0
    }

    do {
      let sourceContentString = try String(contentsOfFile: sourceStringsFilePath)
      var translatedValuesCount = 0

      let sourceTranslations = findTranslations(inString: sourceContentString)
      let existingTargetTranslations = findTranslations(inString: oldContentString)
      var updatedTargetTranslations: [TranslationEntry] = []

      let translator: BartyCrouchTranslator
      switch clientSecret {
      case let .microsoftTranslator(secret):
        translator = .init(translationService: .microsoft(subscriptionKey: secret))

      case let .deepL(secret):
        translator = .init(translationService: .deepL(apiKey: secret))
      }

      for sourceTranslation in sourceTranslations {
        let (sourceKey, sourceValue, sourceComment, sourceLine) = sourceTranslation
        var targetTranslationOptional = existingTargetTranslations.first { $0.key == sourceKey }

        if targetTranslationOptional == nil {
          targetTranslationOptional = (sourceKey, "", sourceComment, sourceLine)
        }

        guard let targetTranslation = targetTranslationOptional else {
          print("targetTranslation was nil when not expected", level: .error, file: path)
          fatalError()
        }

        let (key, value, comment, line) = targetTranslation

        guard value.isEmpty || override else {
          updatedTargetTranslations.append(targetTranslation)
          continue  // skip already translated values
        }

        guard !sourceValue.isEmpty else {
          print(
            "Value for key '\(key)' in source translations is empty.",
            level: .warning,
            file: sourceStringsFilePath,
            line: line
          )
          continue
        }

        let updatedTargetTranslationIndex = updatedTargetTranslations.count
        updatedTargetTranslations.append(targetTranslation)

        switch translator.translate(text: sourceValue, from: sourceTranslatorLanguage, to: [targetTranslatorLanguage]) {
        case let .success(translations):
          if let translatedValue = translations.first?.translatedText {
            if !translatedValue.isEmpty {
              updatedTargetTranslations[updatedTargetTranslationIndex] = (
                key, translatedValue.asStringLiteral, comment, line
              )
              translatedValuesCount += 1
            }
            else {
              print(
                "Resulting translation of '\(sourceValue)' to '\(targetTranslatorLanguage)' was empty.",
                level: .warning,
                file: path,
                line: line
              )
            }
          }
          else {
            print("Could not fetch translation for '\(sourceValue)'.", level: .warning, file: path, line: line)
          }

        case let .failure(failure):
          print(
            "Translation request failed with error: \(failure.errorDescription)",
            level: .warning,
            file: path,
            line: line
          )
        }
      }

      if translatedValuesCount > 0 {
        rewriteFile(
          with: updatedTargetTranslations,
          keepWhitespaceSurroundings: false,
          separateWithEmptyLine: separateWithEmptyLine
        )
      }

      return translatedValuesCount
    }
    catch {
      print(error.localizedDescription, level: .warning, file: path)
      fatalError()
    }
  }

  // - Returns: An array containing all found translations as tuples in the format `(key, value, comment?)`.
  func findTranslations(inString string: String) -> [TranslationEntry] {
    // comment pattern adapted from http://blog.ostermiller.org/find-comment
    let translationRegexString =
      "(?:\\s*/\\*(((?:[^*]|(?:\\*+(?:[^*/])))*))\\*+/\\s*)?\\s*(?:^\\s*\"([\\S  ]*)\"\\s*=\\s*\"(.*?)\"\\s*;\\s*$)"

    // swiftlint:disable force_try
    let translationRegex = try! NSRegularExpression(
      pattern: translationRegexString,
      options: [.dotMatchesLineSeparators, .anchorsMatchLines]
    )
    let newlineRegex = try! NSRegularExpression(pattern: "(\\n)", options: .useUnixLineSeparators)
    // swiftlint:enable force_try

    let positionsOfNewlines = SortedArray(
      newlineRegex.matches(in: string, options: .reportCompletion, range: string.fullRange)
        .map { $0.range(at: 1).location }
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

        let line =
          (positionsOfNewlines.index { $0 > valueRange.location + valueRange.length } ?? positionsOfNewlines.array.count)
          + 1
        return TranslationEntry(key: key, value: value, comment: comment, line: line)
      }
    }

    return translations
  }

  func stringFromTranslations(translations: [TranslationEntry], separateWithEmptyLine: Bool) -> String {
    return
      translations.map { key, value, comment, _ -> String in
        let translationLine = "\"\(key)\" = \"\(value)\";"
        if let comment = comment { return "/*\(comment)*/\n" + translationLine }
        return translationLine
      }
      .joined(separator: separateWithEmptyLine ? "\n\n" : "\n") + "\n"
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
    guard let languageMatch = languageRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last
    else { return nil }
    let language = (path as NSString).substring(with: languageMatch.range(at: 1))

    // Get region from path if existent
    guard let regionMatch = regionRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last else {
      return (language, nil)
    }

    let region = (path as NSString).substring(with: regionMatch.range(at: 1))
    return (language, region)
  }

  func extractLangCode(fromPath path: String) -> String? {
    // Initialize regular expressions -- swiftlint:disable force_try
    let langCodeRegex = try! NSRegularExpression(pattern: "(\\w{2}-{0,1}\\w*)\\.lproj", options: .caseInsensitive)
    // swiftlint:enable force_try

    // Get language from path
    guard let languageMatch = langCodeRegex.matches(in: path, options: .reportCompletion, range: path.fullRange).last
    else { return nil }
    return (path as NSString).substring(with: languageMatch.range(at: 1))
  }

  func findDuplicateEntries() -> [DuplicateEntry] {
    let translations = findTranslations(inString: oldContentString)
    let translationsDict = Dictionary(grouping: translations) { $0.key }
    return translationsDict.filter { $1.count > 1 }.sorted { $0.value[0].line < $1.value[0].line }
  }

  func findEmptyValueEntries() -> [TranslationEntry] {
    let translations = findTranslations(inString: oldContentString)
    return translations.filter { $0.value.isEmpty }
  }

  func harmonizeKeys(withSource sourceFilePath: String, separateWithEmptyLine: Bool) throws {
    let sourceFileContentString = try String(contentsOfFile: sourceFilePath)

    let sourceTranslations = findTranslations(inString: sourceFileContentString)
    let translations = findTranslations(inString: oldContentString)

    var fixedTranslations: [TranslationEntry] = Array(translations)

    let sourceTranslationsDict = Dictionary(grouping: sourceTranslations) { $0.key }
    let translationsDict = Dictionary(grouping: translations) { $0.key }

    let keysToAdd = Set(sourceTranslationsDict.keys).subtracting(translationsDict.keys)
    let keysToRemove = Set(translationsDict.keys).subtracting(sourceTranslationsDict.keys)

    let translationsToAdd = sourceTranslationsDict.filter { keysToAdd.contains($0.key) }.mapValues { $0.first! }
    if !translationsToAdd.isEmpty {
      print("Adding missing keys \(translationsToAdd.keys.sorted()).", level: .info, file: path)
    }

    translationsToAdd.sorted { lhs, rhs in lhs.value.line < rhs.value.line }
      .forEach { translationTuple in
        let translationEntry = translationTuple.value
        let translationEntryWithoutTranslation = (
          key: translationEntry.key, value: "", comment: translationEntry.comment, line: translationEntry.line
        )
        fixedTranslations.append(translationEntryWithoutTranslation)
      }

    if !keysToRemove.isEmpty {
      print("Removing unnecessary keys \(keysToRemove.sorted()).", level: .info, file: path)
    }

    keysToRemove.forEach { keyToRemove in
      fixedTranslations = fixedTranslations.filter { $0.key != keyToRemove }
    }

    rewriteFile(with: fixedTranslations, keepWhitespaceSurroundings: true, separateWithEmptyLine: separateWithEmptyLine)
  }
}

// MARK: - String Extension
extension String {
  /// Unescapes any special characters to make String valid String Literal.
  var asStringLiteral: String {
    let charactersToEscape = ["\\", "\""]  // important: backslash must be first entry
    var escapedString = self

    charactersToEscape.forEach { character in
      escapedString = escapedString.replacingOccurrences(of: character, with: "\\\(character)")
    }

    return escapedString
  }

  func containsAny(of substrings: [String]) -> Bool {
    for substring in substrings {  // swiftlint:disable:this if_as_guard
      if contains(substring) { return true }
    }

    return false
  }
}

extension String {
  var fullRange: NSRange {
    return NSRange(location: 0, length: utf16.count)
  }

  var normalized: String {
    return folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
  }
}
