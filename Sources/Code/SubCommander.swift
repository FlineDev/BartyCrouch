//
//  SubCommander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class SubCommander {
    // MARK: - Sub Types
    public enum ParseError: Error, CustomStringConvertible {
        case missingSubCommand(supportedSubCommands: [String])
        case unsupportedSubCommand(supportedSubCommands: [String])

        public var description: String {
            switch self {
            case let .missingSubCommand(supportedSubCommands):
                return "Missing sub command. Try one of the following: \(supportedSubCommands)"

            case let .unsupportedSubCommand(supportedSubCommands):
                return "Sub command not supported. Try one of the following: \(supportedSubCommands)"
            }
        }
    }

    private struct StderrOutputStream: TextOutputStream {
        static let stream = StderrOutputStream()

        func write(_ string: String) {
            fputs(string, stderr)
        }
    }

    // MARK: - Stored Instance Properties
    private var subCommandLines: [CommandLineParser.SubCommand: () -> CommandLineKit] = [:]

    // MARK: - Instance Methods
    public func addCommandLineBlock(commandLineBlock: @escaping () -> CommandLineKit, forSubCommand subCommand: CommandLineParser.SubCommand) {
        self.subCommandLines[subCommand] = commandLineBlock
    }

    public func commandLine(arguments: [String]) throws -> CommandLineKit {
        guard arguments.count > 1 else {
            throw ParseError.missingSubCommand(supportedSubCommands: CommandLineParser.SubCommand.all().map { $0.rawValue })
        }

        let subCommandString = arguments[1]

        guard let subCommand = CommandLineParser.SubCommand(rawValue: subCommandString), let commandLineBlock = self.subCommandLines[subCommand] else {
            throw ParseError.unsupportedSubCommand(supportedSubCommands: CommandLineParser.SubCommand.all().map { $0.rawValue })
        }

        return commandLineBlock()
    }

    public func printUsage(error: Error) {
        var out = StderrOutputStream.stream
        print("\(error)", terminator: "", to: &out)
    }
}
