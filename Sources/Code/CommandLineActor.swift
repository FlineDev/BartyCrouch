//
//  CommandLineActor.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

// swiftlint:disable function_parameter_count
// swiftlint:disable variable_name

import Foundation

public enum CommandLineAction {
    case interfaces, code, translate
}

public class CommandLineActor {
    // MARK: - Instance Methods
    public func act(commonOptions: CommandLineParser.CommonOptions, subCommandOptions: CommandLineParser.SubCommandOptions) {
        guard let path = commonOptions.path.value else {
            printError("Path option `-p` is missing.")
            exit(EX_USAGE)
        }

        let override = commonOptions.override.value
        let verbose = commonOptions.verbose.value

        switch subCommandOptions {
        case let .codeOptions(localizableOption, defaultToKeysOption, additiveOption, overrideComments, useExtractLocStrings, sortByKeys, unstripped, customFunction): // swiftlint:disable:this line_length
            guard let localizable = localizableOption.value else {
                printError("Localizable option `-l` is missing.")
                exit(EX_USAGE)
            }

            self.actOnCode(
                path: path, override: override, verbose: verbose, localizable: localizable, defaultToKeys: defaultToKeysOption.value,
                additive: additiveOption.value, overrideComments: overrideComments.value, useExtractLocStrings: useExtractLocStrings.value,
                sortByKeys: sortByKeys.value, unstripped: unstripped.value, customFunction: customFunction.value
            )

        case let .interfacesOptions(defaultToBaseOption, unstripped):
            self.actOnInterfaces(path: path, override: override, verbose: verbose, defaultToBase: defaultToBaseOption.value, unstripped: unstripped.value)

        case let .translateOptions(idOption, secretOption, localeOption):
            guard let id = idOption.value else {
                printError("Microsoft Translator API credential 'id' missing. Specify via option `-i`.")
                exit(EX_USAGE)
            }

            guard let secret = secretOption.value else {
                printError("Microsoft Translator API credential 'secret' missing. Specify via option `-s`.")
                exit(EX_USAGE)
            }

            guard let locale = localeOption.value else {
                printError("Locale option `-l` is missing.")
                exit(EX_USAGE)
            }

            self.actOnTranslate(path: path, override: override, verbose: verbose, id: id, secret: secret, locale: locale)
        }
    }

    private func actOnCode(path: String, override: Bool, verbose: Bool, localizable: String, defaultToKeys: Bool, additive: Bool,
                           overrideComments: Bool, useExtractLocStrings: Bool, sortByKeys: Bool, unstripped: Bool, customFunction: String?) {
        let allLocalizableStringsFilePaths = StringsFilesSearch.shared.findAllStringsFiles(within: localizable)

        guard !allLocalizableStringsFilePaths.isEmpty else {
            printError("No `*.strings` file found for output.\nTo fix this, please add a `Localizable.strings` file to your project and click the localize button for the file in Xcode. Custom names for your `*.strings` file do also work. Alternatively remove the line beginning with `bartycrouch code` in your build script to remove this feature entirely if you don't need it.\nSee https://github.com/Flinesoft/BartyCrouch/issues/11 for further information.") // swiftlint:disable:this line_length
            exit(EX_USAGE)
        }

        for localizableStringsFilePath in allLocalizableStringsFilePaths {
            guard FileManager.default.fileExists(atPath: localizableStringsFilePath) else {
                printError("No file exists at output path '\(localizableStringsFilePath)'")
                exit(EX_NOINPUT)
            }
        }

        self.incrementalCodeUpdate(
            inputDirectoryPath: path, allLocalizableStringsFilePaths, override: override, verbose: verbose, defaultToKeys: defaultToKeys,
            additive: additive, overrideComments: overrideComments, useExtractLocStrings: useExtractLocStrings, sortByKeys: sortByKeys,
            unstripped: unstripped, customFunction: customFunction
        )
    }

    private func actOnInterfaces(path: String, override: Bool, verbose: Bool, defaultToBase: Bool, unstripped: Bool) {
        let inputFilePaths = StringsFilesSearch.shared.findAllIBFiles(within: path, withLocale: "Base")

        guard !inputFilePaths.isEmpty else {
            printError("No input files found.")
            exit(EX_USAGE)
        }

        for inputFilePath in inputFilePaths {
            guard FileManager.default.fileExists(atPath: inputFilePath) else {
                printError("No file exists at input path '\(inputFilePath)'")
                exit(EX_NOINPUT)
            }

            let outputStringsFilePaths = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: inputFilePath).filter { $0 != inputFilePath }

            for outputStringsFilePath in outputStringsFilePaths {
                guard FileManager.default.fileExists(atPath: outputStringsFilePath) else {
                    printError("No file exists at output path '\(outputStringsFilePath)'.")
                    exit(EX_CONFIG)
                }
            }

            self.incrementalInterfacesUpdate(
                inputFilePath, outputStringsFilePaths, override: override, verbose: verbose, defaultToBase: defaultToBase, unstripped: unstripped
            )
        }
    }

    private func actOnTranslate(path: String, override: Bool, verbose: Bool, id: String, secret: String, locale: String) {
        let inputFilePaths = StringsFilesSearch.shared.findAllStringsFiles(within: path, withLocale: locale)

        guard !inputFilePaths.isEmpty else {
            printError("No input files found.")
            exit(EX_USAGE)
        }

        for inputFilePath in inputFilePaths {
            guard FileManager.default.fileExists(atPath: inputFilePath) else {
                printError("No file exists at input path '\(inputFilePath)'")
                exit(EX_NOINPUT)
            }

            let outputStringsFilePaths = StringsFilesSearch.shared.findAllLocalesForStringsFile(sourceFilePath: inputFilePath).filter { $0 != inputFilePath }

            for outputStringsFilePath in outputStringsFilePaths {
                guard FileManager.default.fileExists(atPath: outputStringsFilePath) else {
                    printError("No file exists at output path '\(outputStringsFilePath)'.")
                    exit(EX_CONFIG)
                }
            }

            self.translate(id: id, secret: secret, inputFilePath, outputStringsFilePaths, override: override, verbose: verbose)
        }
    }

    private func incrementalCodeUpdate(
        inputDirectoryPath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool, defaultToKeys: Bool,
        additive: Bool, overrideComments: Bool, useExtractLocStrings: Bool, sortByKeys: Bool, unstripped: Bool, customFunction: String?
    ) {
        let extractedStringsFileDirectory = inputDirectoryPath + "/tmpstrings/"

        do {
            try FileManager.default.createDirectory(atPath: extractedStringsFileDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
            exit(EX_IOERR)
        }

        let codeCommander: CodeCommander = useExtractLocStrings ? ExtractLocStringsCommander.shared : GenStringsCommander.shared

        guard codeCommander.export(
            stringsFilesToPath: extractedStringsFileDirectory, fromCodeInDirectoryPath: inputDirectoryPath, customFunction: customFunction
        ) else {
            printError("Could not extract strings from Code in directory '\(inputDirectoryPath)'.")
            exit(EX_UNAVAILABLE)
        }

        for outputStringsFilePath in outputStringsFilePaths {
            guard let fileName = outputStringsFilePath.components(separatedBy: "/").last else {
                printError("Could not extract name of string file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            var extractedLocalizableStringsFilePath = extractedStringsFileDirectory + fileName
            if !FileManager.default.fileExists(atPath: extractedLocalizableStringsFilePath) {
                extractedLocalizableStringsFilePath = extractedStringsFileDirectory + "Localizable.strings"

                guard FileManager.default.fileExists(atPath: extractedLocalizableStringsFilePath) else {
                    printError("No localizations extracted from Code for string file '\(outputStringsFilePath)'.")
                    continue
                }
            }

            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            stringsFileUpdater.incrementallyUpdateKeys(
                withStringsFileAtPath: extractedLocalizableStringsFilePath, addNewValuesAsEmpty: !defaultToKeys,
                override: override, keepExistingKeys: additive, overrideComments: overrideComments, sortByKeys: sortByKeys,
                keepWhitespaceSurroundings: unstripped
            )

            if verbose { print("Incrementally updated keys of file '\(outputStringsFilePath)'.") }
        }

        do {
            try FileManager.default.removeItem(atPath: extractedStringsFileDirectory)
        } catch {
            printError("Temporary strings files couldn't be deleted at path '\(extractedStringsFileDirectory)'")
            exit(EX_IOERR)
        }

        print("BartyCrouch: Successfully updated strings file(s) of Code files.")
    }

    private func incrementalInterfacesUpdate(
        _ inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool, defaultToBase: Bool, unstripped: Bool
    ) {
        let extractedStringsFilePath = inputFilePath + ".tmpstrings"

        guard IBToolCommander.shared.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputFilePath) else {
            printError("Could not extract strings from Storyboard or XIB at path '\(inputFilePath)'.")
            exit(EX_UNAVAILABLE)
        }

        for outputStringsFilePath in outputStringsFilePaths {
            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            stringsFileUpdater.incrementallyUpdateKeys(
                withStringsFileAtPath: extractedStringsFilePath,
                addNewValuesAsEmpty: !defaultToBase,
                override: override,
                keepWhitespaceSurroundings: unstripped
            )

            if verbose {
                print("Incrementally updated keys of file '\(outputStringsFilePath)'.")
            }
        }

        do {
            try FileManager.default.removeItem(atPath: extractedStringsFilePath)
        } catch {
            printError("Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'")
            exit(EX_IOERR)
        }

        print("BartyCrouch: Successfully updated strings file(s) of Storyboard or XIB file.")
    }

    private func translate(id: String, secret: String, _ inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool) {
        var overallTranslatedValuesCount = 0
        var filesWithTranslatedValuesCount = 0

        for outputStringsFilePath in outputStringsFilePaths {
            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            let translationsCount = stringsFileUpdater.translateEmptyValues(
                usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret, override: override
            )

            if verbose { print("Translated file '\(outputStringsFilePath)' with \(translationsCount) changes.") }

            if translationsCount > 0 {
                overallTranslatedValuesCount += translationsCount
                filesWithTranslatedValuesCount += 1
            }
        }

        print("BartyCrouch: Successfully translated \(overallTranslatedValuesCount) values in \(filesWithTranslatedValuesCount) files.")
    }

    // MARK: - Helper Methods
    private func printError(_ message: String) {
        print("Error! \(message)")
    }
}

// swiftlint:enable function_parameter_count
// swiftlint:enable variable_name
