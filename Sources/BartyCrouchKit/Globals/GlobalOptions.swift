import Foundation
import SwiftCLI

public enum GlobalOptions {
    static let verbose = Flag("-v", "--verbose", description: "Prints more detailed information about the executed command")
    static let xcodeOutput = Flag("-x", "--xcode-output", description: "Prints warnings & errors in Xcode compatible format")
    static let failOnWarnings = Flag("-w", "--fail-on-warnings", description: "Returns a failed status code if any warning is encountered")

    public static var all: [Option] {
        return [verbose, xcodeOutput, failOnWarnings]
    }
}
