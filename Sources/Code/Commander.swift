//
//  Commander.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 04.06.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

class Commander {
    // MARK: - Define Sub Structures

    typealias CommandLineResult = (outputs: [String], errors: [String], exitCode: Int32)


    // MARK: - Stored Type Properties

    static let shared = Commander()


    // MARK: - Instance Methods

    func run(command: String, arguments: [String]?) -> CommandLineResult {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments

        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe

        task.launch()

        var outputs: [String] = []
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()

        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            outputs = string.components(separatedBy: "\n")
        }

        var errors: [String] = []
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()

        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            errors = string.components(separatedBy: "\n")
        }

        task.waitUntilExit()
        let status = task.terminationStatus

        return (outputs, errors, status)
    }
}
