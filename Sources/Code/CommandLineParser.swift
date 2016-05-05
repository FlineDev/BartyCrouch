//
//  CommandLineParser.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class CommandLineParser {

    // MARK: - Define Sub Structures
    
    public enum SubCommand: String {
        case Code = "code"
        case Interfaces = "interfaces"
        case Translate = "translate"
        
        static func all() -> [SubCommand] {
            return [.Code, .Interfaces, .Translate]
        }
    }
    
    public typealias CommonOptions = (path: StringOption, override: BoolOption, verbose: BoolOption)
    private typealias CommandLineContext = (commandLine: CommandLine, commonOptions: CommonOptions, subCommandOptions: SubCommandOptions)
    
    public enum SubCommandOptions {
        case CodeOptions(defaultToBase: BoolOption)
        case InterfacesOptions(defaultToBase: BoolOption)
        case TranslateOptions(id: StringOption, secret: StringOption)
    }

    
    // MARK: - Stored Instance Properties
    
    var commonOptions: CommonOptions?
    var subCommandOptions: SubCommandOptions?
    
    let arguments: [String]
    
    
    // MARK: - Initializers
    
    public init(arguments: [String] = Process.arguments) {
        self.arguments = arguments
    }
    
    
    // MARK: - Instance Methods
    
    public func parse() {
        
        let subCommander = self.setupSubCommander()
        var commandLine: CommandLine!
        
        do {
            commandLine = try subCommander.commandLine(arguments)
        } catch {
            subCommander.printUsage(error)
            exit(EX_USAGE)
        }
        
        do {
            try commandLine.parse()
        } catch {
            commandLine.printUsage(error)
            exit(EX_USAGE)
        }
        
    }
    
    private func setupSubCommander() -> SubCommander {

        let subCommander = SubCommander()
        
        for subCommand in SubCommand.all() {
            let (commandLine, commonOptions, subCommandOptions) = self.setupCLI(forSubCommand: subCommand)
            self.commonOptions = commonOptions
            self.subCommandOptions = subCommandOptions
            subCommander.addCommandLine(commandLine, forSubCommand: subCommand)
        }
        
        return subCommander
    }
    
    private func setupCLI(forSubCommand subCommand: SubCommand) -> CommandLineContext {
        
        switch subCommand {
        case .Code:
            return self.setupCodeCLI()
        case .Interfaces:
            return self.setupInterfacesCLI()
        case .Translate:
            return self.setupTranslateCLI()
        }
        
    }
    
    private func setupCodeCLI() -> CommandLineContext {
        
        let commandLine = CommandLine(arguments: self.arguments(forSubCommand: .Code))
        
        
        // Required
        
        let path = self.pathOption(
            helpMessage: "Set the base path to recursively search within for code files (.h, .m, .swift)."
        )
        
        // Optional
        
        let override = self.overrideOption(
            helpMessage: "Overrides existing translation values and comments. Use carefully."
        )
        
        let verbose = self.verboseOption()
        
        let defaultToBase = self.defaultToBaseOption(
            helpMessage: "Uses the values from the Base localized Code files when adding new keys."
        )
        
        
        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.CodeOptions(defaultToBase: defaultToBase)
        
        commandLine.addOptions(path, override, verbose, defaultToBase)
        
        return (commandLine, commonOptions, subCommandOptions)
        
    }
    
    private func setupInterfacesCLI() -> CommandLineContext {
        
        let commandLine = CommandLine(arguments: self.arguments(forSubCommand: .Interfaces))
        
        
        // Required
        
        let path = self.pathOption(
            helpMessage: "Set the base path to recursively search within for Interface Builder files (.xib, .storyboard)."
        )
        
        // Optional
        
        let override = self.overrideOption(
            helpMessage: "Overrides existing translation values and comments. Use carefully."
        )
        
        let verbose = self.verboseOption()
        
        let defaultToBase = self.defaultToBaseOption(
            helpMessage: "Uses the values from the Base localized Interface Builder files when adding new keys."
        )
        
        
        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.InterfacesOptions(defaultToBase: defaultToBase)
        
        commandLine.addOptions(path, override, verbose, defaultToBase)
        
        return (commandLine, commonOptions, subCommandOptions)
    }
    
    private func setupTranslateCLI() -> CommandLineContext {
        
        let commandLine = CommandLine(arguments: self.arguments(forSubCommand: .Translate))
        
        
        // Required Options
        
        let path = self.pathOption(
            helpMessage: "Set the base path to recursively search within for Strings files (.strings)."
        )
        
        let id = StringOption(
            shortFlag: "i",
            longFlag: "id",
            required: true,
            helpMessage: "Your Microsoft Translator API credentials 'id' value."
        )
        
        let secret = StringOption(
            shortFlag: "s",
            longFlag: "secret",
            required: true,
            helpMessage: "Your Microsoft Translator API credentials 'secret' value."
        )
        
        // Optional
        
        let override = self.overrideOption(
            helpMessage: "Overrides existing translation values. Use carefully."
        )
        
        let verbose = self.verboseOption()
        
        
        let commonOptions: CommonOptions = (path: path, override: override, verbose: verbose)
        let subCommandOptions = SubCommandOptions.TranslateOptions(id: id, secret: secret)
        
        commandLine.addOptions(path, id, secret, override, verbose)
        
        return (commandLine, commonOptions, subCommandOptions)
    }
    
    
    // MARK: - Option Creator Methods
    
    private func pathOption(helpMessage helpMessage: String) -> StringOption {
        return StringOption(
            shortFlag: "p",
            longFlag: "path",
            required: true,
            helpMessage: helpMessage
        )
    }
    
    private func overrideOption(helpMessage helpMessage: String) -> BoolOption {
        return BoolOption(
            shortFlag: "o",
            longFlag: "override",
            required: false,
            helpMessage: helpMessage
        )
    }
    
    private func verboseOption() -> BoolOption {
        return BoolOption(
            shortFlag: "v",
            longFlag: "verbose",
            required: false,
            helpMessage: "Prints out more status information to the console."
        )
    }
    
    private func defaultToBaseOption(helpMessage helpMessage: String) -> BoolOption {
        return BoolOption(
            shortFlag: "b",
            longFlag: "default-to-base",
            required: false,
            helpMessage: helpMessage
        )
    }
    
    private func arguments(forSubCommand subCommand: SubCommand) -> [String] {
        return arguments.filter { $0 != subCommand.rawValue }
    }
    
}
