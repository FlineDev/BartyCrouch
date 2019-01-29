// Created by Cihat Gündüz on 07.11.18.

import Foundation
import SwiftCLI

public class LintCommand: Command {
    // MARK: - Command
    public let name: String = "lint"
    public let shortDescription: String = "Lints your .strings file contents"

    // MARK: - Initializers
    public init() {}

    // MARK: - Instance Methods
    public func execute() throws {
        let lintOptions = try Configuration.load().lintOptions
        LintTaskHandler(options: lintOptions).perform()
        CommandExecution.current.failIfNeeded()
    }
}
