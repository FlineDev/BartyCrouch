//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class CommandLineParser {
    // MARK: - Sub Types
    public enum SubCommand: String {
        case code
        case interfaces
        case translate
        case normalize
        case lint

        static func all() -> [SubCommand] {
            return [.code, .interfaces, .translate, .normalize, .lint]
        }
    }

    public typealias CommonOptions = (path: StringOption, override: BoolOption, verbose: BoolOption)
    private typealias CommandLineContext = (commandLine: CommandLineKit, commonOptions: CommonOptions, subCommandOptions: SubCommandOptions)

    public enum SubCommandOptions {
        case codeOptions(
            localizable: StringOption,
            defaultToKeys: BoolOption,
            additive: BoolOption,
            overrideComments: BoolOption,
            useExtractLocStrings: BoolOption,
            sortByKeys: BoolOption,
            unstripped: BoolOption,
            customFunction: StringOption,
            customLocalizableName: StringOption
        )
        case interfacesOptions(defaultToBase: BoolOption, unstripped: BoolOption)
        case translateOptions(id: StringOption, secret: StringOption, locale: StringOption)
        case normalizeOptions(
            locale: StringOption,
            preventDuplicateKeys: BoolOption,
            sortByKeys: BoolOption,
            warnEmptyValues: BoolOption,
            harmonizeWithSource: BoolOption
        )
        case lintOptions(emptyValues: BoolOption, duplicateKeys: BoolOption)
    }

    // MARK: - Stored Instance Properties
    private var commonOptions: CommonOptions?
    private var subCommandOptions: SubCommandOptions?

    let arguments: [String]

    // MARK: Options
    private let defaultToKeys = BoolOption(
        shortFlag: "k",
        longFlag: "default-to-keys",
        required: false,
        helpMessage: "Uses the keys as values when adding new keys from code."
    )

    private let additive = BoolOption(
        shortFlag: "a",
        longFlag: "additive",
        required: false,
        helpMessage: "Only adds new keys keeping all existing keys even when seemingly unused."
    )

    private let overrideComments = BoolOption(
        shortFlag: "c",
        longFlag: "override-comments",
        required: false,
        helpMessage: "Overrides existing translation comments."
    )

    private let useExtractLocStrings = BoolOption(
        shortFlag: "e",
        longFlag: "extract-loc-strings",
        required: false,
        helpMessage: "Uses the extractLocStrings tool instead of genstrings."
    )

    private let sortByKeys = BoolOption(
        shortFlag: "s",
        longFlag: "sort-by-keys",
        required: false,
        helpMessage: "Sorts the entries in the resulting Strings file by keys."
    )

    private let unstripped = BoolOption(
        shortFlag: "u",
        longFlag: "unstripped",
        required: false,
        helpMessage: "Keep newlines at beginning/end of Strings files."
    )

    private let customFunction = StringOption(
        shortFlag: "f",
        longFlag: "custom-function",
        required: false,
        helpMessage: "Specifies a custom function to be searched for instead of NSLocalizedString."
    )

    private let customLocalizableName = StringOption(
        shortFlag: "n",
        longFlag: "custom-localizable-name",
        required: false,
        helpMessage: "Specified a custom name for the Strings file instead of the default `Localizable.strings`."
    )

    private let preventDuplicateKeys = BoolOption(
        shortFlag: "d",
        longFlag: "prevent-duplicate-keys",
        required: false,
        helpMessage: "Warns if Strings files contain duplicate keys or removes duplicates automatically if values are equal."
    )

    private let warnEmptyValues = BoolOption(
        shortFlag: "w",
        longFlag: "warn-empty-values",
        required: false,
        helpMessage: "Warns if Strings files contain keys with empty values. Designed to be used as part of Xcode build scripts."
    )

    private let harmonizeWithSource = BoolOption(
        shortFlag: "h",
        longFlag: "harmonize-with-source",
        required: false,
        helpMessage: "Makes sure all languages have exactly the same keys as the source language specified with `-l`."
    )

    private let lintEmptyValues = BoolOption(
        shortFlag: "e",
        longFlag: "empty-values",
        required: false,
        helpMessage: "Fails if Strings files contain keys with empty values. Designed to be used as part of a CI service."
    )

    private let lintDuplicateKeys = BoolOption(
        shortFlag: "d",
        longFlag: "duplicate-keys",
        required: false,
        helpMessage: "Fails if Strings files contain duplicate keys. Designed to be used as part of a CI service."
    )

    // MARK: - Initializers
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    // MARK: - Instance Methods
    public func parse(completion: (_ commonOptions: CommonOptions, _ subCommandOptions: SubCommandOptions) -> Void) {
        let subCommander = self.setupSubCommander()
        var commandLine: CommandLineKit!

        do {
            commandLine = try subCommander.commandLine(arguments: arguments)
        } catch {
            subCommander.printUsage(error: error)
            exit(EX_USAGE)
        }

        do {
            try commandLine.parse()
        } catch {
            commandLine.printUsage(error)
            exit(EX_USAGE)
        }

        guard let commonOptions = self.commonOptions, let subCommandOptions = self.subCommandOptions else {
            print("Could not read options properly. Please report here: https://github.com/Flinesoft/BartyCrouch/issues", level: .error)
            exit(EX_SOFTWARE)
        }

        completion(commonOptions, subCommandOptions)
    }

    private func setupSubCommander() -> SubCommander {
        let subCommander = SubCommander()

        for subCommand in SubCommand.all() {
            let commandLineBlock: () -> CommandLineKit = {
                let (commandLine, commonOptions, subCommandOptions) = self.setupCLI(for: subCommand)
                self.commonOptions = commonOptions
                self.subCommandOptions = subCommandOptions
                return commandLine
            }

            subCommander.addCommandLineBlock(commandLineBlock: commandLineBlock, forSubCommand: subCommand)
        }

        return subCommander
    }

    private func setupCLI(for subCommand: SubCommand) -> CommandLineContext {
        switch subCommand {
        case .code:
            return self.setupCodeCLI()

        case .interfaces:
            return self.setupInterfacesCLI()

        case .translate:
            return self.setupTranslateCLI()

        case .normalize:
            return self.setupNormalizeCLI()

        case .lint:
            return self.setupLintCLI()
        }
    }

    private func setupCodeCLI() -> CommandLineContext {
        let commandLine = CommandLineKit(arguments: self.arguments(for: .code))

        // Required
        let path = self.pathOption(helpMessage: "Set the base path to recursively search within for code files (.h, .m, .mm, .swift).")

        let localizable = StringOption(shortFlag: "l", longFlag: "localizable", required: true,
                                       helpMessage: "The path to the folder of your output `Localizable.strings` file to be updated.")

        // Optional
        let override = self.overrideOption(helpMessage: "Overrides existing translation values and comments. Use carefully.")
        let verbose = self.verboseOption()

        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.codeOptions(
            localizable: localizable, defaultToKeys: defaultToKeys, additive: additive, overrideComments: overrideComments,
            useExtractLocStrings: useExtractLocStrings, sortByKeys: sortByKeys, unstripped: unstripped, customFunction: customFunction,
            customLocalizableName: customLocalizableName
        )

        commandLine.addOptions(
            path, localizable, override, verbose, defaultToKeys, additive, overrideComments,
            useExtractLocStrings, sortByKeys, unstripped, customFunction, customLocalizableName
        )

        return (commandLine, commonOptions, subCommandOptions)
    }

    private func setupInterfacesCLI() -> CommandLineContext {
        let commandLine = CommandLineKit(arguments: self.arguments(for: .interfaces))

        // Required
        let path = self.pathOption(helpMessage: "Set the base path to recursively search within for Interface Builder files (.xib, .storyboard).")

        // Optional
        let override = self.overrideOption(helpMessage: "Overrides existing translation values and comments. Use carefully.")
        let verbose = self.verboseOption()

        let defaultToBase = BoolOption(
            shortFlag: "b", longFlag: "default-to-base", required: false,
            helpMessage: "Uses the values from the Base localized Interface Builder files when adding new keys."
        )
        let unstripped = BoolOption(
            shortFlag: "u", longFlag: "unstripped", required: false,
            helpMessage: "Keep newlines at beginning/end of Strings files."
        )

        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.interfacesOptions(defaultToBase: defaultToBase, unstripped: unstripped)

        commandLine.addOptions(path, override, verbose, defaultToBase, unstripped)
        return (commandLine, commonOptions, subCommandOptions)
    }

    private func setupTranslateCLI() -> CommandLineContext {
        let commandLine = CommandLineKit(arguments: self.arguments(for: .translate))

        // Required Options
        let path = self.pathOption(helpMessage: "Set the base path to recursively search within for Strings files (.strings).")
        let id = StringOption(shortFlag: "i", longFlag: "id", required: true, helpMessage: "Your Microsoft Translator API credentials 'id' value.")
        let secret = StringOption(shortFlag: "s", longFlag: "secret", required: true, helpMessage: "Your Microsoft Translator API credentials 'secret' value.")
        let locale = StringOption(shortFlag: "l", longFlag: "locale", required: true,
                                  helpMessage: "Specify the source locale from which to translate the values to other languages.")

        // Optional
        let override = self.overrideOption(helpMessage: "Overrides existing translation values. Use carefully.")
        let verbose = self.verboseOption()

        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.translateOptions(id: id, secret: secret, locale: locale)

        commandLine.addOptions(path, id, secret, locale, override, verbose)
        return (commandLine, commonOptions, subCommandOptions)
    }

    private func setupNormalizeCLI() -> CommandLineContext {
        let commandLine = CommandLineKit(arguments: self.arguments(for: .normalize))

        // Required
        let path = self.pathOption(helpMessage: "Set the base path to recursively search within for Strings files (.strings).")
        let locale = StringOption(
            shortFlag: "l",
            longFlag: "locale",
            required: true,
            helpMessage: "Specify the source locale from which to normalize other languages Strings files (.strings)."
        )

        // Optional
        let override = self.overrideOption(helpMessage: "Overrides existing translation values. Use carefully.") // NOTE: probably not needed here
        let verbose = self.verboseOption()

        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.normalizeOptions(
            locale: locale,
            preventDuplicateKeys: preventDuplicateKeys,
            sortByKeys: sortByKeys,
            warnEmptyValues: warnEmptyValues,
            harmonizeWithSource: harmonizeWithSource
        )

        commandLine.addOptions(path, locale, preventDuplicateKeys, sortByKeys, warnEmptyValues, harmonizeWithSource, override, verbose)
        return (commandLine, commonOptions, subCommandOptions)
    }

    private func setupLintCLI() -> CommandLineContext {
        let commandLine = CommandLineKit(arguments: self.arguments(for: .lint))

        // Required
        let path = self.pathOption(helpMessage: "Set the base path to recursively search within for Strings files (.strings).")

        // Optional
        let override = self.overrideOption(helpMessage: "Overrides existing translation values. Use carefully.") // NOTE: probably not needed here
        let verbose = self.verboseOption()

        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.lintOptions(emptyValues: lintEmptyValues, duplicateKeys: lintDuplicateKeys)

        commandLine.addOptions(path, lintEmptyValues, lintDuplicateKeys)
        return (commandLine, commonOptions, subCommandOptions)
    }

    // MARK: - Option Creator Methods
    private func pathOption(helpMessage: String) -> StringOption {
        return StringOption(shortFlag: "p", longFlag: "path", required: true, helpMessage: helpMessage)
    }

    private func overrideOption(helpMessage: String) -> BoolOption {
        return BoolOption(shortFlag: "o", longFlag: "override", required: false, helpMessage: helpMessage)
    }

    private func verboseOption() -> BoolOption {
        return BoolOption(shortFlag: "v", longFlag: "verbose", required: false, helpMessage: "Prints out more status information to the console.")
    }

    private func arguments(for subCommand: SubCommand) -> [String] {
        return arguments.filter { $0 != subCommand.rawValue }
    }
}
