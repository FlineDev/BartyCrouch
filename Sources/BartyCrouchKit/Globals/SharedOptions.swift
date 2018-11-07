// Created by Cihat Gündüz on 07.11.18.

import Foundation
import SwiftCLI

public enum SharedOptions {
    static let verbose = Flag("-v", "--verbose", description: "Prints more detailed information about the executed command")

    public static var all: [Option] {
        return [verbose]
    }
}
