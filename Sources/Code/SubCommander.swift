//
//  SubCommander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 05.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

public class SubCommander {
    
    // MARK: - Define Sub Structures
    
    public enum ParseError: ErrorType, CustomStringConvertible {
        case MissingSubCommand(supportedSubCommands: [String])
        case UnsupportedSubCommand(supportedSubCommands: [String])
        
        public var description: String {
            switch self {
            case let .MissingSubCommand(supportedSubCommands):
                return "Missing sub command. Try one of the following: \(supportedSubCommands)"
            case let .UnsupportedSubCommand(supportedSubCommands):
                return "Sub command not supported. Try one of the following: \(supportedSubCommands)"
            }
        }
    }
    
    private struct StderrOutputStream: OutputStreamType {
        static let stream = StderrOutputStream()
        func write(s: String) {
            fputs(s, stderr)
        }
    }
    
    
    // MARK: - Stored Instance Properties
    
    private var subCommandLines: [CommandLineParser.SubCommand: () -> CommandLine] = [:]
    
  
    // MARK: - Instance Methods
    
    public func addCommandLineBlock(commandLineBlock: () -> CommandLine, forSubCommand subCommand: CommandLineParser.SubCommand) {
        self.subCommandLines[subCommand] = commandLineBlock
    }
    
    public func commandLine(arguments: [String]) throws -> CommandLine {
        guard arguments.count > 1 else {
            throw ParseError.MissingSubCommand(supportedSubCommands: CommandLineParser.SubCommand.all().map{ $0.rawValue })
        }
        
        let subCommandString = arguments[1]
        
        guard let subCommand = CommandLineParser.SubCommand(rawValue: subCommandString), commandLineBlock = self.subCommandLines[subCommand] else {
            throw ParseError.UnsupportedSubCommand(supportedSubCommands: CommandLineParser.SubCommand.all().map{ $0.rawValue })
        }
        
        return commandLineBlock()
    }
    
    public func printUsage(error: ErrorType) {
        var out = StderrOutputStream.stream
        print("\(error)", terminator: "", toStream: &out)
    }
    
}
