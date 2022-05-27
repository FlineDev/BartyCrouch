// swiftlint:disable function_parameter_count type_body_length cyclomatic_complexity

import BartyCrouchUtility
import Foundation

// NOTE:
// This file was not refactored as port of the work/big-refactoring branch for version 4.0 to prevent unexpected behavior changes.
// A rewrite after writing extensive tests for the expected behavior could improve readebility, extensibility and performance.

public enum CommandLineAction {
  case interfaces
  case code
  case translate
}

public class CommandLineActor {
  public init() {}

  func actOnCode(
    paths: [String],
    subpathsToIgnore: [String],
    override: Bool,
    verbose: Bool,
    localizables: [String],
    defaultToKeys: Bool,
    additive: Bool,
    overrideComments: Bool,
    unstripped: Bool,
    customFunction: String?,
    customLocalizableName: String?,
    usePlistArguments: Bool,
    ignoreKeys: [String]
  ) {
    let localizableFileName = customLocalizableName ?? "Localizable"
    let allLocalizableStringsFilePaths =
      localizables.flatMap {
        StringsFilesSearch.shared.findAllStringsFiles(
          within: $0,
          withFileName: localizableFileName,
          subpathsToIgnore: subpathsToIgnore
        )
      }
      .withoutDuplicates()

    guard !allLocalizableStringsFilePaths.isEmpty else {
      print(
        "No `\(localizableFileName).strings` file found for output.\nTo fix this, please add a `\(localizableFileName).strings` file to your project and click the localize button for the file in Xcode. Alternatively remove the line beginning with `bartycrouch code` in your build script to remove this feature entirely if you don't need it.\nSee https://github.com/Flinesoft/BartyCrouch/issues/11 for further information.",
        level: .error
      )
      return
    }

    self.incrementalCodeUpdate(
      inputDirectoryPaths: paths,
      subpathsToIgnore: subpathsToIgnore,
      allLocalizableStringsFilePaths,
      override: override,
      verbose: verbose,
      defaultToKeys: defaultToKeys,
      additive: additive,
      overrideComments: overrideComments,
      unstripped: unstripped,
      customFunction: customFunction,
      localizableFileName: localizableFileName,
      usePlistArguments: usePlistArguments,
      ignoreKeys: ignoreKeys
    )
  }

  func actOnInterfaces(
    paths: [String],
    subpathsToIgnore: [String],
    override: Bool,
    verbose: Bool,
    defaultToBase: Bool,
    unstripped: Bool,
    ignoreEmptyStrings: Bool,
    ignoreKeys: [String]
  ) {
    let inputFilePaths =
      paths.flatMap {
        StringsFilesSearch.shared.findAllIBFiles(within: $0, subpathsToIgnore: subpathsToIgnore, withLocale: "Base")
      }
      .withoutDuplicates()

    guard !inputFilePaths.isEmpty else { print("No input files found.", level: .warning); return }

    for inputFilePath in inputFilePaths {
      guard FileManager.default.fileExists(atPath: inputFilePath) else {
        print("No file exists at input path '\(inputFilePath)'", level: .error); return
      }

      let outputStringsFilePaths = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: inputFilePath)
        .filter { $0 != inputFilePath }
      self.incrementalInterfacesUpdate(
        inputFilePath,
        outputStringsFilePaths,
        override: override,
        verbose: verbose,
        defaultToBase: defaultToBase,
        unstripped: unstripped,
        ignoreEmptyStrings: ignoreEmptyStrings,
        ignoreKeys: ignoreKeys
      )
    }
  }

  func actOnTranslate(
    paths: [String],
    subpathsToIgnore: [String],
    override: Bool,
    verbose: Bool,
    secret: Secret,
    locale: String,
    separateWithEmptyLine: Bool
  ) {
    let inputFilePaths =
      paths.flatMap {
        StringsFilesSearch.shared.findAllStringsFiles(
          within: $0,
          withLocale: locale,
          subpathsToIgnore: subpathsToIgnore
        )
      }
      .withoutDuplicates()

    guard !inputFilePaths.isEmpty else { print("No input files found.", level: .warning); return }

    for inputFilePath in inputFilePaths {
      guard FileManager.default.fileExists(atPath: inputFilePath) else {
        print("No file exists at input path '\(inputFilePath)'.", level: .error); return
      }

      let outputStringsFilePaths = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: inputFilePath)
        .filter { $0 != inputFilePath }
      self.translate(
        secret: secret,
        inputFilePath,
        outputStringsFilePaths,
        override: override,
        verbose: verbose,
        separateWithEmptyLine: separateWithEmptyLine
      )
    }
  }

  func actOnNormalize(
    paths: [String],
    subpathsToIgnore: [String],
    override: Bool,
    verbose: Bool,
    locale: String,
    sortByKeys: Bool,
    harmonizeWithSource: Bool,
    separateWithEmptyLine: Bool
  ) {
    let sourceFilePaths =
      paths.flatMap {
        StringsFilesSearch.shared.findAllStringsFiles(
          within: $0,
          withLocale: locale,
          subpathsToIgnore: subpathsToIgnore
        )
      }
      .withoutDuplicates()
    guard !sourceFilePaths.isEmpty else { print("No source language files found.", level: .warning); return }

    for sourceFilePath in sourceFilePaths {
      guard FileManager.default.fileExists(atPath: sourceFilePath) else {
        print("No file exists at input path '\(sourceFilePath)'.", level: .error)
        continue
      }

      let allStringsFilePaths = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: sourceFilePath)
      let targetStringsFilePaths = allStringsFilePaths.filter { $0 != sourceFilePath }

      for targetStringsFilePath in targetStringsFilePaths {
        guard FileManager.default.fileExists(atPath: targetStringsFilePath) else {
          print("No file exists at other language path '\(targetStringsFilePath)'.", level: .error)
          continue
        }
      }

      if harmonizeWithSource {
        for filePath in targetStringsFilePaths {
          let stringsFileUpdater = StringsFileUpdater(path: filePath)
          do {
            try stringsFileUpdater?
              .harmonizeKeys(withSource: sourceFilePath, separateWithEmptyLine: separateWithEmptyLine)
          }
          catch {
            print("Could not harmonize keys with source file at path \(sourceFilePath).", level: .error)
            continue
          }
        }
      }

      if sortByKeys {
        for filePath in allStringsFilePaths {
          let stringsFileUpdater = StringsFileUpdater(path: filePath)
          stringsFileUpdater?.sortByKeys(separateWithEmptyLine: separateWithEmptyLine)
        }
      }
    }
  }

  func actOnLint(paths: [String], subpathsToIgnore: [String], duplicateKeys: Bool, emptyValues: Bool) {
    let stringsFilePaths =
      paths.flatMap {
        StringsFilesSearch.shared.findAllStringsFiles(within: $0, subpathsToIgnore: subpathsToIgnore)
      }
      .withoutDuplicates()
    guard !stringsFilePaths.isEmpty else { print("No Strings files found.", level: .warning); return }

    let totalChecks: Int = [duplicateKeys, emptyValues].filter { $0 }.count

    if totalChecks <= 0 {
      print(
        "No checks specified. Run `bartycrouch lint` to see all available linting options.",
        level: .warning,
        file: paths.last
      )
    }

    var failedFilePaths: [String] = []
    var totalFails = 0

    for stringsFilePath in stringsFilePaths {
      guard FileManager.default.fileExists(atPath: stringsFilePath) else {
        print("No file exists at file path '\(stringsFilePath)'.", level: .error, file: stringsFilePath); return
      }

      let stringsFileUpdater = StringsFileUpdater(path: stringsFilePath)
      var lintingFailed = false

      if duplicateKeys {
        let duplicateKeyEntries: [StringsFileUpdater.DuplicateEntry] = stringsFileUpdater!.findDuplicateEntries()
        for (duplicateKey, translations) in duplicateKeyEntries {
          for translation in translations {
            let otherSameKeyTranslationsLines: [Int] = translations.compactMap {
              $0.line == translation.line ? nil : $0.line
            }
            print(
              "Found \(translations.count) translations for key '\(duplicateKey)'. Other entries at: \(otherSameKeyTranslationsLines)",
              level: .warning,
              file: stringsFilePath,
              line: translation.line
            )
          }
        }

        if !duplicateKeyEntries.isEmpty {
          lintingFailed = true
          totalFails += duplicateKeyEntries.count
        }
      }

      if emptyValues {
        let emptyValueEntries: [StringsFileUpdater.TranslationEntry] = stringsFileUpdater!.findEmptyValueEntries()
        for translation in emptyValueEntries {
          print(
            "Found empty value for key '\(translation.key)'.",
            level: .warning,
            file: stringsFilePath,
            line: translation.line
          )
        }

        if !emptyValueEntries.isEmpty {
          lintingFailed = true
          totalFails += emptyValueEntries.count
        }
      }

      if lintingFailed {
        failedFilePaths.append(stringsFilePath)
      }
    }

    if !failedFilePaths.isEmpty {
      print(
        "\(totalFails) issue(s) found in \(failedFilePaths.count) file(s). Executed \(totalChecks) checks in \(stringsFilePaths.count) Strings file(s) in total.",
        level: .warning,
        file: paths.last
      )
    }
    else {
      print(
        "\(totalChecks) check(s) passed for \(stringsFilePaths.count) Strings file(s).",
        level: .success,
        file: paths.last
      )
    }
  }

  private func incrementalCodeUpdate(
    inputDirectoryPaths: [String],
    subpathsToIgnore: [String],
    _ outputStringsFilePaths: [String],
    override: Bool,
    verbose: Bool,
    defaultToKeys: Bool,
    additive: Bool,
    overrideComments: Bool,
    unstripped: Bool,
    customFunction: String?,
    localizableFileName: String,
    usePlistArguments: Bool,
    ignoreKeys: [String]
  ) {
    for inputDirectoryPath in inputDirectoryPaths {
      let extractedStringsFileDirectory = inputDirectoryPath + "/tmpstrings/"

      do {
        try FileManager.default.createDirectory(
          atPath: extractedStringsFileDirectory,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }
      catch {
        print(error.localizedDescription, level: .error)
        return
      }

      do {
        try CodeCommander.shared.export(
          stringsFilesToPath: extractedStringsFileDirectory,
          fromCodeInDirectoryPath: inputDirectoryPath,
          customFunction: customFunction,
          usePlistArguments: usePlistArguments,
          subpathsToIgnore: subpathsToIgnore
        )
      }
      catch {
        print("Could not extract strings from Code in directory '\(inputDirectoryPath)'.", level: .error)
        return
      }

      let extractedLocalizableStringsFilePath = extractedStringsFileDirectory + "Localizable.strings"
      guard FileManager.default.fileExists(atPath: extractedLocalizableStringsFilePath) else {
        print("No localizations extracted from Code in directory '\(inputDirectoryPath)'.", level: .warning)

        // BUGFIX: Remove empty /tmpstrings/ folder again.
        try? FileManager.default.removeItem(atPath: extractedStringsFileDirectory)

        return  // NOTE: Expecting to see this only for empty project situations.
      }

      for outputStringsFilePath in outputStringsFilePaths {
        guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else { continue }

        stringsFileUpdater.incrementallyUpdateKeys(
          withStringsFileAtPath: extractedLocalizableStringsFilePath,
          addNewValuesAsEmpty: !defaultToKeys,
          ignoreBaseKeysAndComment: ignoreKeys,
          override: override,
          keepExistingKeys: additive,
          overrideComments: overrideComments,
          keepWhitespaceSurroundings: unstripped
        )

        if verbose { print("Incrementally updated keys of file '\(outputStringsFilePath)'.", level: .info) }
      }

      do {
        try FileManager.default.removeItem(atPath: extractedStringsFileDirectory)
      }
      catch {
        print("Temporary strings files couldn't be deleted at path '\(extractedStringsFileDirectory)'", level: .error)
        return
      }

      print("Successfully updated strings file(s) of Code files.", level: .success, file: inputDirectoryPath)
    }
  }

  private func incrementalInterfacesUpdate(
    _ inputFilePath: String,
    _ outputStringsFilePaths: [String],
    override: Bool,
    verbose: Bool,
    defaultToBase: Bool,
    unstripped: Bool,
    ignoreEmptyStrings: Bool,
    ignoreKeys: [String]
  ) {
    let extractedStringsFilePath = inputFilePath + ".tmpstrings"

    do {
      try IBToolCommander.shared.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputFilePath)
    }
    catch {
      print("Could not extract strings from Storyboard or XIB at path '\(inputFilePath)'.", level: .error)
      return
    }

    for outputStringsFilePath in outputStringsFilePaths {
      guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else { continue }

      stringsFileUpdater.incrementallyUpdateKeys(
        withStringsFileAtPath: extractedStringsFilePath,
        addNewValuesAsEmpty: !defaultToBase,
        ignoreBaseKeysAndComment: ignoreKeys,
        override: override,
        keepWhitespaceSurroundings: unstripped,
        ignoreEmptyStrings: ignoreEmptyStrings
      )

      if verbose {
        print("Incrementally updated keys of file '\(outputStringsFilePath)'.", level: .info)
      }
    }

    do {
      try FileManager.default.removeItem(atPath: extractedStringsFilePath)
    }
    catch {
      print("Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'", level: .error)
      return
    }

    print("Successfully updated strings file(s) of Storyboard or XIB file.", level: .success, file: inputFilePath)
  }

  private func translate(
    secret: Secret,
    _ inputFilePath: String,
    _ outputStringsFilePaths: [String],
    override: Bool,
    verbose: Bool,
    separateWithEmptyLine: Bool
  ) {
    var overallTranslatedValuesCount = 0
    var filesWithTranslatedValuesCount = 0

    for outputStringsFilePath in outputStringsFilePaths {
      guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else { continue }

      mungo.do {
        let translationsCount = try stringsFileUpdater.translateEmptyValues(
          usingValuesFromStringsFile: inputFilePath,
          clientSecret: secret,
          separateWithEmptyLine: separateWithEmptyLine,
          override: override
        )

        if verbose {
          print("Translated file '\(outputStringsFilePath)' with \(translationsCount) changes.", level: .info)
        }

        if translationsCount > 0 {
          overallTranslatedValuesCount += translationsCount
          filesWithTranslatedValuesCount += 1
        }
      }
    }

    print(
      "Successfully translated \(overallTranslatedValuesCount) values in \(filesWithTranslatedValuesCount) files.",
      level: .success,
      file: inputFilePath
    )
  }
}
