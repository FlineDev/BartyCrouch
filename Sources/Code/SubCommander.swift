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
    
    private var subCommandLines: [String: CommandLine] = [:]
    
  
    // MARK: - Instance Methods
    
    public func addCommandLine(commandLine: CommandLine, forSubCommand subCommand: String) {
        self.subCommandLines[subCommand] = commandLine
    }
    
    public func commandLine(forArguments arguments: [String] = Process.arguments) throws -> CommandLine {
        guard let subCommand = arguments.first else {
            throw ParseError.MissingSubCommand(supportedSubCommands: self.subCommandLines.map { $0.0 })
        }
        
        guard let commandLine = self.subCommandLines[subCommand] else {
            throw ParseError.UnsupportedSubCommand(supportedSubCommands: self.subCommandLines.map { $0.0 })
        }
        
        return commandLine
    }
    
    public func printUsage(error: ErrorType) {
        var out = StderrOutputStream.stream
        print("\(error)", terminator: "", toStream: &out)
    }
    
}
