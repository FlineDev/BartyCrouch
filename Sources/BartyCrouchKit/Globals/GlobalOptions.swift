// Created by Cihat Gündüz on 07.11.18.

import Foundation
import SwiftCLI

public enum GlobalOptions {
    static let verbose = Flag("-v", "--verbose", description: "Prints more detailed information about the executed command")
    static let xcodeOutput = Flag("-x", "--xcode-output", description: "Prints warnings & errors in Xcode compatible format")

    public static var all: [Option] {
        return [verbose]
    }
}
