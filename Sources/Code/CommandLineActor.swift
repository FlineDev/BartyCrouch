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
    case Interfaces()
    case Code()
    case Translate()
}

public class CommandLineActor {

    // MARK: - Instance Methods

    public func act(commonOptions: CommandLineParser.CommonOptions, subCommandOptions: CommandLineParser.SubCommandOptions) {

        guard let path = commonOptions.path.value else {
            self.printError("Path option `-p` is missing.")
            exit(EX_USAGE)
        }

        let override = commonOptions.override.value
        let verbose = commonOptions.verbose.value


        switch subCommandOptions {
        case let .CodeOptions(localizableOption, defaultToKeysOption, additiveOption, overrideComments, useExtractLocStrings, sortByKeys):
            guard let localizable = localizableOption.value else {
                self.printError("Localizable option `-l` is missing.")
                exit(EX_USAGE)
            }

            self.actOnCode(path: path, override: override, verbose: verbose, localizable: localizable, defaultToKeys: defaultToKeysOption.value, additive: additiveOption.value,
                           overrideComments: overrideComments.value, useExtractLocStrings: useExtractLocStrings.value, sortByKeys: sortByKeys.value)

        case let .InterfacesOptions(defaultToBaseOption):
            self.actOnInterfaces(path: path, override: override, verbose: verbose, defaultToBase: defaultToBaseOption.value)

        case let .TranslateOptions(idOption, secretOption, localeOption):
            guard let id = idOption.value else {
                self.printError("Microsoft Translator API credential 'id' missing. Specify via option `-i`.")
                exit(EX_USAGE)
            }

            guard let secret = secretOption.value else {
                self.printError("Microsoft Translator API credential 'secret' missing. Specify via option `-s`.")
                exit(EX_USAGE)
            }

            guard let locale = localeOption.value else {
                self.printError("Locale option `-l` is missing.")
                exit(EX_USAGE)
            }

            self.actOnTranslate(path: path, override: override, verbose: verbose, id: id, secret: secret, locale: locale)
        }

    }

// swiftlint:disable line_length
    private func actOnCode(path: String, override: Bool, verbose: Bool, localizable: String, defaultToKeys: Bool, additive: Bool,
                           overrideComments: Bool, useExtractLocStrings: Bool, sortByKeys: Bool) {
// swiftlint:enable line_length

        let allLocalizableStringsFilePaths = StringsFilesSearch.sharedInstance.findAllStringsFiles(baseDirectoryPath: localizable, withFileName: "Localizable")

        guard !allLocalizableStringsFilePaths.isEmpty else {
            self.printError("No `Localizable.strings` file found for output.\nTo fix this, please add a `Localizable.strings` file to your project and click the localize button for the file in Xcode. Alternatively remove the line beginning with `bartycrouch code` in you build script to remove this feature entirely if you don't need it.\nSee https://github.com/Flinesoft/BartyCrouch/issues/11 for further information.") // swiftlint:disable:this line_length
            exit(EX_USAGE)
        }

        for localizableStringsFilePath in allLocalizableStringsFilePaths {

            guard FileManager.default.fileExists(atPath: localizableStringsFilePath) else {
                self.printError("No file exists at output path '\(localizableStringsFilePath)'")
                exit(EX_NOINPUT)
            }

        }

        self.incrementalCodeUpdate(inputDirectoryPath: path, allLocalizableStringsFilePaths, override: override, verbose: verbose, defaultToKeys: defaultToKeys,
                                   additive: additive, overrideComments: overrideComments, useExtractLocStrings: useExtractLocStrings, sortByKeys: sortByKeys)

    }

    private func actOnInterfaces(path: String, override: Bool, verbose: Bool, defaultToBase: Bool) {

        let inputFilePaths = StringsFilesSearch.sharedInstance.findAllIBFiles(baseDirectoryPath: path, withLocale: "Base")

        guard !inputFilePaths.isEmpty else {
            self.printError("No input files found.")
            exit(EX_USAGE)
        }

        for inputFilePath in inputFilePaths {

            guard FileManager.default.fileExists(atPath: inputFilePath) else {
                self.printError("No file exists at input path '\(inputFilePath)'")
                exit(EX_NOINPUT)
            }

            let outputStringsFilePaths = StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(sourceFilePath: inputFilePath).filter { $0 != inputFilePath }

            for outputStringsFilePath in outputStringsFilePaths {
                guard FileManager.default.fileExists(atPath: outputStringsFilePath) else {
                    self.printError("No file exists at output path '\(outputStringsFilePath)'.")
                    exit(EX_CONFIG)
                }
            }

            self.incrementalInterfacesUpdate(inputFilePath, outputStringsFilePaths, override: override, verbose: verbose, defaultToBase: defaultToBase)

        }

    }

    private func actOnTranslate(path: String, override: Bool, verbose: Bool, id: String, secret: String, locale: String) {

        let inputFilePaths = StringsFilesSearch.sharedInstance.findAllStringsFiles(baseDirectoryPath: path, withLocale: locale)

        guard !inputFilePaths.isEmpty else {
            self.printError("No input files found.")
            exit(EX_USAGE)
        }

        for inputFilePath in inputFilePaths {

            guard FileManager.default.fileExists(atPath: inputFilePath) else {
                self.printError("No file exists at input path '\(inputFilePath)'")
                exit(EX_NOINPUT)
            }

            let outputStringsFilePaths = StringsFilesSearch.sharedInstance.findAllLocalesForStringsFile(sourceFilePath: inputFilePath).filter { $0 != inputFilePath }

            for outputStringsFilePath in outputStringsFilePaths {
                guard FileManager.default.fileExists(atPath: outputStringsFilePath) else {
                    self.printError("No file exists at output path '\(outputStringsFilePath)'.")
                    exit(EX_CONFIG)
                }
            }

            self.translate(id: id, secret: secret, inputFilePath, outputStringsFilePaths, override: override, verbose: verbose)

        }


    }

    private func incrementalCodeUpdate(inputDirectoryPath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool, defaultToKeys: Bool,
                                       additive: Bool, overrideComments: Bool, useExtractLocStrings: Bool, sortByKeys: Bool) {

        let extractedStringsFileDirectory = inputDirectoryPath + "/tmpstrings/"

        do {
            try FileManager.default.createDirectory(atPath: extractedStringsFileDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
            exit(EX_IOERR)
        }

        let codeCommander: CodeCommander = useExtractLocStrings
            ? ExtractLocStringsCommander.sharedInstance
            : GenStringsCommander.sharedInstance

        guard codeCommander.export(stringsFilesToPath: extractedStringsFileDirectory, fromCodeInDirectoryPath: inputDirectoryPath) else {
            self.printError("Could not extract strings from Code in directory '\(inputDirectoryPath)'.")
            exit(EX_UNAVAILABLE)
        }

        let extractedLocalizableStringsFilePath = extractedStringsFileDirectory + "Localizable.strings"

        for outputStringsFilePath in outputStringsFilePaths {

            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                self.printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedLocalizableStringsFilePath, addNewValuesAsEmpty: !defaultToKeys,
                                                       override: override, keepExistingKeys: additive, overrideComments: overrideComments, sortByKeys: sortByKeys)

            if verbose {
                print("Incrementally updated keys of file '\(outputStringsFilePath)'.")
            }

        }

        do {
            try FileManager.default.removeItem(atPath: extractedStringsFileDirectory)
        } catch {
            self.printError("Temporary strings files couldn't be deleted at path '\(extractedStringsFileDirectory)'")
            exit(EX_IOERR)
        }

        print("BartyCrouch: Successfully updated strings file(s) of Code files.")
    }

    private func incrementalInterfacesUpdate(_ inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool, defaultToBase: Bool) {
        let extractedStringsFilePath = inputFilePath + ".tmpstrings"

        guard IBToolCommander.sharedInstance.export(stringsFileToPath: extractedStringsFilePath, fromIbFileAtPath: inputFilePath) else {
            self.printError("Could not extract strings from Storyboard or XIB at path '\(inputFilePath)'.")
            exit(EX_UNAVAILABLE)
        }

        for outputStringsFilePath in outputStringsFilePaths {

            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                self.printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            stringsFileUpdater.incrementallyUpdateKeys(withStringsFileAtPath: extractedStringsFilePath, addNewValuesAsEmpty: !defaultToBase, override: override)

            if verbose {
                print("Incrementally updated keys of file '\(outputStringsFilePath)'.")
            }

        }

        do {
            try FileManager.default.removeItem(atPath: extractedStringsFilePath)
        } catch {
            self.printError("Temporary strings file couldn't be deleted at path '\(extractedStringsFilePath)'")
            exit(EX_IOERR)
        }

        print("BartyCrouch: Successfully updated strings file(s) of Storyboard or XIB file.")
    }

    private func translate(id: String, secret: String, _ inputFilePath: String, _ outputStringsFilePaths: [String], override: Bool, verbose: Bool) {

        var overallTranslatedValuesCount = 0
        var filesWithTranslatedValuesCount = 0

        for outputStringsFilePath in outputStringsFilePaths {

            guard let stringsFileUpdater = StringsFileUpdater(path: outputStringsFilePath) else {
                self.printError("Could not read strings file at path '\(outputStringsFilePath)'")
                exit(EX_CONFIG)
            }

            let translationsCount = stringsFileUpdater.translateEmptyValues(usingValuesFromStringsFile: inputFilePath, clientId: id, clientSecret: secret, override: override)

            if verbose {
                print("Translated file '\(outputStringsFilePath)' with \(translationsCount) changes.")
            }

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
